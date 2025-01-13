local M = {}

-- Option: default_im
-- Default input method for normal mode other than insert mode.
-- Default value for macOS: "com.apple.keylayout.ABC".
-- Defalt value for Windows: "1033".
local default_im
local os_name = vim.uv.os_uname().sysname
if os_name:match("Windows") then
    default_im = "1033"
elseif os_name:match("Darwin") then
    default_im = "com.apple.keylayout.ABC"
else
    -- Only works on Windows and macOS.
    vim.api.nvim_err_writeln([[Plugin neovim-im-select only works on Windows and macOS.]])
    return
end

-- Option: im_select_cmd
-- Command of im-select, leave it "im-select" if im-select is in $PAth, or set it to the path of the executable `im-select`.
-- Default value : "im-select".
local im_select_cmd = "im-select"

-- Option: insert_im
-- The input method specified for Insert, Replace and Select mode. 
-- If it is set, always switch to it when entering Insert, Replace and Select mode.
-- If it is not set, the insert mode IM will be auto obtained and saved IM when leaving Insert, Replace and Select mode.
-- Default value: nil.
local insert_im = nil

-- Option: enable_im_select
-- Whether enable switching input method automatically.
-- Set it to false/0 to disable it, or any other value to enable it.
-- Default value: true.
local enable_im_select = true

-- Option: enable_on_focus_events
-- Enable or disable switching input method automatically on FocusLost and FocusGained events.
-- Set it to false/0 to disable it, or any other value to enable it.
-- If you have set to switch IM among different windows/applications by other ways, you should set it to false. 
-- Note that the IM of external applications is the same as the IM of Insert mode.
-- Default value is false.
local enable_on_focus_events = false

-- Previous IM that saved for Insert mode.
local previous_im

-- Update configuration
M.config = function(opts)
    if type(opts) == "table" then
        if opts.im_select_cmd ~= nil then
            im_select_cmd = opts.im_select_cmd
        end
        if opts.default_im ~= nil then
            default_im = opts.default_im
        end
        if opts.insert_im ~= nil then
            insert_im = opts.insert_im
        end
        if opts.enable_im_select == false or opts.enable_im_select == 0 then
            enable_on_focus_events = false
        end
        if opts.enable_on_focus_events and opts.enable_on_focus_events ~= 0 then
            enable_on_focus_events = true
        end
    end
end

-- Callback fuctions of autocmds.
local switch_to_default, switch_to_previous, obtain_and_switch_to_default

-- Obtain and switch to default IM command.
local obtain_and_switch_command

local vim_fn_system, vim_system, vim_fn_mode = vim.fn.system, vim.system, vim.fn.mode

-- Define functions for autocmds.
local define_autocmd_functions = function()
    -- Switch to default IM
    switch_to_default = function()
        vim_system({im_select_cmd, default_im})
    end

    -- Switch to previous IM that obtained before.
    -- If insert_im is set, switch to insert IM.
    switch_to_previous = (function(specified_insert_im)
        if specified_insert_im then
            return function()
                vim_system({im_select_cmd, specified_insert_im})
            end
        else
            return function()
                vim_system({im_select_cmd, previous_im})
            end
        end
    end)(insert_im)

    -- Command of obtaining current IM and switching to default IM.
    obtain_and_switch_command = im_select_cmd .. " & " .. im_select_cmd .. " " .. default_im

    -- Obtain current IM and switch to default IM.
    -- If insert_im is set, no need to obtain current IM, only switch to default IM.
    obtain_and_switch_to_default = (function(specified_insert_im)
        if specified_insert_im then
            return switch_to_default
        else
            return function()
                previous_im = vim_fn_system(obtain_and_switch_command):sub(1, -2)
            end
        end
    end)(insert_im)
end
-- Auto switch IM autocommand group name.
local IM_SELECT_AUGROUP = "ImSelectAugroup"

-- Create autocmds on focus enevts
local create_focus_event_autocmds = function()
    -- Nvim lost focus, switch back to the previous IM if in normal mode, otherwise do nothing.
    vim.api.nvim_create_autocmd("FocusLost", {
        group = IM_SELECT_AUGROUP,
        callback = function()
            local mode = vim_fn_mode()
            -- Switch to previous IM if not in insert mode or replace mode
            if mode ~= "i" and mode ~= "R" then
                switch_to_previous()
            end
        end
    })

    -- Nvim got focus, switch to the default IM if in normal mode, otherwise do nothing.
    vim.api.nvim_create_autocmd("FocusGained", {
        group = IM_SELECT_AUGROUP,
        callback = function()
            local mode = vim_fn_mode()
            -- Switch to default IM if not in insert mode or replace mode.
            if mode ~= "i" and mode ~= "R" then
                obtain_and_switch_to_default()
            end
        end
    })
end

-- Create autocmds on mode changed events.
local create_im_select_autocmds = function()
    vim.api.nvim_create_augroup(IM_SELECT_AUGROUP, {
        clear = true
    })

    -- Enter insert mode or leave Nvim, switch back to previous IM.
    vim.api.nvim_create_autocmd({"InsertEnter", "VimLeave"}, {
        group = IM_SELECT_AUGROUP,
        callback = switch_to_previous
    })

    -- Leave insert mode or enter Nvim, obtain current IM and switch to default IM.
    vim.api.nvim_create_autocmd("InsertLeave", {
        group = IM_SELECT_AUGROUP,
        callback = obtain_and_switch_to_default
    })

    -- Leave cmdline mode, switch to default IM.
    vim.api.nvim_create_autocmd("CmdlineLeave", {
        group = IM_SELECT_AUGROUP,
        callback = switch_to_default
    })

    if enable_on_focus_events then
        create_focus_event_autocmds()
    end
end

-- Creat commands for user.
local create_user_commands = function()
    -- Command to enable/disabled pulgin neovim-im-select.
    vim.api.nvim_create_user_command("ImSelectToggle", function()
        if enable_im_select then
            vim.notify("Disable Neovim-im-select.", vim.log.levels.INFO)
            enable_im_select = false
            vim.api.nvim_del_augroup_by_name(IM_SELECT_AUGROUP)
        else
            vim.notify("Enable Neovim-im-select.", vim.log.levels.INFO)
            enable_im_select = true
            create_im_select_autocmds()
        end
    end, {})

    -- Command to turn on/off switching input method automatically on FocusLost and FocusGained events.
    vim.api.nvim_create_user_command("ImSelectFocusEventToggle", function()
        if not enable_im_select then
            vim.notify("Neovim-im-select has been disenabled. Enable it by using command `ImSelectToggle` first.",
                vim.log.levels.WARN)
            return
        end
        if enable_on_focus_events then
            vim.notify("Turn off auto switching IM on focus events.", vim.log.levels.INFO)
            enable_on_focus_events = false
            vim.api.nvim_clear_autocmds({
                event = {"FocusLost", "FocusGained"},
                group = IM_SELECT_AUGROUP
            })
        else
            vim.notify("Turn on auto switching IM on focus events.", vim.log.levels.INFO)
            enable_on_focus_events = true
            create_focus_event_autocmds()
        end
    end, {})
end

-- Setup plugin.
M.setup = function(opts)
    M.config(opts)
    if vim.fn.executable(im_select_cmd) ~= 1 then
        vim.api.nvim_err_writeln(
            [[Plugin neovim-im-select requires `im-select` to be installed, repo url: https://github.com/daipeihust/im-select .]])
        return
    end

    define_autocmd_functions()

    -- Swicth to default IM when starting Nvim.
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = obtain_and_switch_to_default,
        once = true
    })

    create_user_commands()
    if enable_im_select then
        create_im_select_autocmds()
    end
end

return M
