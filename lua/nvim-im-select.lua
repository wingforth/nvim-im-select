-- Only works on Windows and macOS platforms.
local platform = vim.uv.os_uname().sysname
if platform:match("Windows") then
    platform = "Windows"
elseif platform:match("Darwin") then
    platform = "macOS"
else
    vim.notify([[Plugin neovim-im-select only works on Windows and macOS platforms.]], vim.log.levels.INFO)
    return
end

local M = {}

-- ===Start of default options=== --

-- Option: [string] default_im
-- Default input method for Normal mode other than Insert mode.
-- Default value for macOS: "com.apple.keylayout.ABC".
-- Default value for Windows: "1033".
local default_im = platform == "Windows" and "1033" or "com.apple.keylayout.ABC"

-- Option: [string] im_select_cmd
-- Command of im-select, leave it "im-select" if im-select is in $PAth, or set it to the path of the executable `im-select`.
-- Default value : "im-select".
local im_select_cmd = "im-select"

-- Option: [string] insert_im
-- The input method specified for Insert and Replace mode. 
-- If user sets option `insert_im`, always switch to it when entering Insert and Replace mode.
-- If user doesn't set option `insert_im`, the Insert mode IM will be auto obtained and saved when leaving Insert or Replace mode.
-- Default value: nil.
local insert_im = nil

-- Option: [boolean] enable_im_select
-- Whether enable switching input method automatically.
-- Set it to `false` to disable it, or `true` to enable it.
-- Default value: true.
local enable_im_select = true

-- Option: [boolean] enable_on_focus_events
-- Whether enable switching input method automatically on FocusLost and FocusGained events.
-- Set it to `false` to disable it, or `true` to enable it.
-- If you have set to switch IM among different windows/applications by other ways, you should set it to false. 
-- Note that the IM of external applications is the same as the IM of Insert mode.
-- Default value: false.
local enable_on_focus_events = false

-- ===End of default options=== --

-- Function reference
local system = vim.system or vim.fn.system
-- Callback functions of autocommand.
local switch_to_default_im, switch_to_insert_im, obtain_and_switch_to_default_im
-- Commands of switching input method.
local switch_to_default_im_cmd, switch_to_insert_im_cmd, obtain_and_switch_to_default_im_cmd
-- Autocommand group name of auto-switch input method.
local IM_SELECT_AUGROUP = "NvimImSelectAugroup"

-- Update configuration
local update_config = function(opts)
    if type(opts) == "table" then
        if opts.im_select_cmd ~= nil then
            im_select_cmd = opts.im_select_cmd
        end
        if opts.default_im ~= nil then
            default_im = opts.default_im
        end
        if opts.enable_im_select == false then
            enable_im_select = false
        end
        if opts.enable_on_focus_events == true then
            enable_on_focus_events = true
        end
        insert_im = opts.insert_im
    end
end

-- Define functions of switching input method.
local define_switch_functions = function(specified)
    switch_to_default_im_cmd = {im_select_cmd, default_im}
    if specified then
        switch_to_default_im = function()
            system(switch_to_default_im_cmd)
        end
        switch_to_insert_im_cmd = {im_select_cmd, insert_im}
        switch_to_insert_im = function()
            system(switch_to_insert_im_cmd)
        end
        -- If insert IM is specified, obtain_and_switch_to_default_im is same as switch_to_default_im.
        obtain_and_switch_to_default_im = switch_to_default_im
    else
        switch_to_default_im = function()
            if default_im ~= insert_im then
                system(switch_to_default_im_cmd)
            end
        end
        switch_to_insert_im = function()
            if default_im ~= insert_im then
                system({im_select_cmd, insert_im})
            end
        end
        obtain_and_switch_to_default_im_cmd = vim.fn.flatten(
            {vim.o.shell, vim.fn.split(vim.o.shellcmdflag),
             im_select_cmd .. (vim.o.shell == "cmd.exe" and " & " or "; ") .. im_select_cmd .. " " .. default_im})
        if vim.system then
            obtain_and_switch_to_default_im = function()
                -- -- asynchronously
                -- system(obtain_and_switch_to_default_im_cmd, function(obj) insert_im = vim.trim(obj.stdout) end)
                -- synchronously
                insert_im = vim.trim(system(obtain_and_switch_to_default_im_cmd):wait().stdout)
            end
        else
            obtain_and_switch_to_default_im = function()
                insert_im = vim.trim(system(obtain_and_switch_to_default_im_cmd))
            end
        end
    end
end

-- Create autocmds on focus events.
local handle_focus_events = function()
    -- Neovim lost focus, switch to the Insert mode IM if not in Insert or Replace mode, otherwise do nothing.
    vim.api.nvim_create_autocmd("FocusLost", {
        group = IM_SELECT_AUGROUP,
        callback = function()
            local mode = vim.fn.mode()
            if mode ~= "i" and mode ~= "R" then
                switch_to_insert_im()
            end
        end
    })
    -- Neovim got focus, switch to the default IM if not in Insert or Replace mode, otherwise do nothing.
    vim.api.nvim_create_autocmd("FocusGained", {
        group = IM_SELECT_AUGROUP,
        callback = function()
            local mode = vim.fn.mode()
            if mode ~= "i" and mode ~= "R" then
                obtain_and_switch_to_default_im()
            end
        end
    })
end

-- Create autocmds on mode changed events.
local create_im_select_autocmds = function()
    vim.api.nvim_create_augroup(IM_SELECT_AUGROUP, {
        clear = true
    })
    -- Enter Insert mode or leave Neovim, switch back to Insert mode IM.
    vim.api.nvim_create_autocmd({"InsertEnter", "VimLeave"}, {
        group = IM_SELECT_AUGROUP,
        callback = switch_to_insert_im
    })
    -- Leave Insert mode or enter Neovim, obtain current IM and switch to default IM.
    vim.api.nvim_create_autocmd("InsertLeave", {
        group = IM_SELECT_AUGROUP,
        callback = obtain_and_switch_to_default_im
    })
    -- Enter search Cmdline mode, switch to Insert mode IM.
    vim.api.nvim_create_autocmd("CmdlineEnter", {
        group = IM_SELECT_AUGROUP,
        pattern = {"/", "?"},
        callback = switch_to_insert_im
    })
    -- Leave search Cmdline mode, switch to default IM.
    vim.api.nvim_create_autocmd("CmdlineLeave", {
        group = IM_SELECT_AUGROUP,
        pattern = {"/", "?"},
        callback = switch_to_default_im
    })
    if enable_on_focus_events then
        handle_focus_events()
    end
end

-- Create commands for user.
local create_user_commands = function()
    -- Command to enable/disable auto-switch input method.
    vim.api.nvim_create_user_command("ImSelectToggle", function()
        if enable_im_select then
            vim.notify([[[neovim-im-select] Auto-switch IM disabled.]], vim.log.levels.INFO)
            enable_im_select = false
            vim.api.nvim_del_augroup_by_name(IM_SELECT_AUGROUP)
        else
            vim.notify([[[neovim-im-select] Auto-switch IM enabled.]], vim.log.levels.INFO)
            enable_im_select = true
            create_im_select_autocmds()
        end
    end, {})
    -- Command to enable/disable auto-switch input method on FocusLost and FocusGained events.
    vim.api.nvim_create_user_command("ImSelectFocusEventToggle", function()
        if not enable_im_select then
            vim.notify([[Neovim-im-select has been disabled. Enable it by using command `ImSelectToggle` first.]],
                vim.log.levels.WARN)
            return
        end
        if enable_on_focus_events then
            vim.notify([[[neovim-im-select] Auto-switch IM on focus events disabled.]], vim.log.levels.INFO)
            enable_on_focus_events = false
            vim.api.nvim_clear_autocmds({
                event = {"FocusLost", "FocusGained"},
                group = IM_SELECT_AUGROUP
            })
        else
            vim.notify([[[neovim-im-select] Auto-switch IM on focus events enabled.]], vim.log.levels.INFO)
            enable_on_focus_events = true
            handle_focus_events()
        end
    end, {})
end

-- Setup plugin.
M.setup = function(opts)
    update_config(opts)
    if vim.fn.executable(im_select_cmd) ~= 1 then
        vim.notify(
            [[Plugin neovim-im-select requires `im-select` to be installed, repo url: https://github.com/daipeihust/im-select .]],
            vim.log.levels.ERROR)
        return
    end
    define_switch_functions(opts.insert_im ~= nil)
    if enable_im_select then
        -- Init insert mode IM and switch to default IM when launching neovim.
        obtain_and_switch_to_default_im()
        create_im_select_autocmds()
    end
    create_user_commands()
end

return M
