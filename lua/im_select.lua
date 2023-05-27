local M = {}

-- Option: default_im
-- Default input method for normal mode other than insert mode.
-- Default value for macOS: "com.apple.keylayout.ABC".
-- Defalt value for Windows: "1033".
local default_im
local system = vim.loop.os_uname().sysname
if system == "Windows_NT" then
	default_im = "1033"
elseif system == "Darwin" then
	default_im = "com.apple.keylayout.ABC"
else
	-- Only works on Windows and macOS
	vim.api.nvim_err_writeln([[Plugin neovim-im-select only works on Windows and macOS.]])
	return
end

-- Option: im_select_cmd
-- Command of im-select, leave it "im-select" if im-select is in $PAth, or set it to the path of the executable `im-select`.
-- Default value : "im-select".
local im_select_cmd = "im-select"

-- Option: enable_on_focus_events
-- Enable or disable switching input method automatically on FocusLost and FocusGained events.
-- Set it to false/0 to disable it, or any other value to enable it.
-- If you have set up other ways to switch IM among different windows/applications, you may want to set this option to false. 
-- Default value is true.
local enable_on_focus_events = true

-- Previous IM that saved for insert mode
local previous_im

-- Update configuration
M.config = function(opts)
	if opts.im_select_cmd ~= nil then
		im_select_cmd = opts.im_select_cmd
	end

	if opts.default_im ~= nil then
		default_im = opts.default_im
	end

	if opts.enable_on_focus_events == false or opts.enable_on_focus_events == 0 then
		enable_on_focus_events = false
	end
end

-- Obtain current IM and switch to default IM
local obtain_and_switch_to_default = function()
	previous_im = vim.trim(vim.fn.system({ im_select_cmd }))
	if previous_im ~= default_im then
		vim.fn.system({ im_select_cmd, default_im })
	end
end

-- Switch to default IM
local switch_to_default = function(im)
	vim.fn.system({ im_select_cmd, default_im })
end

-- Switch to previous IM that obtained before
local switch_to_previous = function(im)
	vim.fn.system({ im_select_cmd, previous_im })
end

-- Switch to previous IM with a delay
local switch_to_previous_with_delay = function()
	vim.defer_fn(function()
		vim.fn.system({ im_select_cmd, previous_im })
	end, 100)
end

-- Create autocmds on mode changed events
local create_mode_event_autocmds = function()
	local on_mode_events = "ImSelectOnModeEvents"
	vim.api.nvim_create_augroup(on_mode_events, { clear = true })

	-- Leave insert mode or enter Nvim, obtain current IM and swith to default IM
	vim.api.nvim_create_autocmd({ "InsertLeave", "VimEnter" }, {
		group = on_mode_events,
		callback = obtain_and_switch_to_default,
	})

	-- Leave cmdline mode, swith to default IM
	vim.api.nvim_create_autocmd("CmdlineLeave", {
		group = on_mode_events,
		callback = switch_to_default,
	})

	-- Enter insert mode or leave Nvim, swith back to previous IM
	vim.api.nvim_create_autocmd({ "InsertEnter", "VimLeave" }, {
		group = on_mode_events,
		callback = switch_to_previous,
	})
end

-- Focus enevt autocmd group name
local on_focus_events = "ImSelectOnFocusEvents"
-- Create autocmds on focus enevts
local create_focus_event_autocmds = function()
	vim.api.nvim_create_augroup(on_focus_events, { clear = true })

	-- Nvim lost focus, switch back to the previous IM if in normal mode, otherwise do nothing
	vim.api.nvim_create_autocmd("FocusLost", {
		group = on_focus_events,
		callback = function()
			local mode = vim.fn.mode()
			-- Switch to previous IM if not in insert mode or replace mode
			if mode ~= "i" and mode ~= "R" then
				switch_to_previous_with_delay()
			end
		end,
	})

	-- Nvim got focus, switch to the default IM if in normal mode, otherwise do nothing
	vim.api.nvim_create_autocmd("FocusGained", {
		group = on_focus_events,
		callback = function()
			local mode = vim.fn.mode()
			-- Switch to default IM if not in insert mode or replace mode
			if mode ~= "i" and mode ~= "R" then
				obtain_and_switch_to_default()
			end
		end,
	})
end

-- Create or clear autocmds on focus events
local focus_events_toggle = function()
	if vim.g.im_select_enable_on_focus_events == true then
		vim.g.im_select_enable_on_focus_events = false
		vim.api.nvim_clear_autocmds({ group = on_focus_events })
	else
		vim.g.im_select_enable_on_focus_events = true
		create_focus_event_autocmds()
	end
end

-- Command to turn on/off switching input method automatically on FocusLost and FocusGained events.
vim.api.nvim_create_user_command("IMSelectOnFocusEventsToggle", focus_events_toggle, {})

M.setup = function(opts)
	if type(opts) == "table" then
		M.config(opts)
	end

	if vim.fn.executable(im_select_cmd) ~= 1 then
		vim.api.nvim_err_writeln(
			[[Plugin neovim-im-select requires `im-select` to be installed, repo url: https://github.com/daipeihust/im-select .]]
		)
		return
	end

	previous_im = default_im
	vim.api.nvim_set_var("im_select_enable_on_focus_events", enable_on_focus_events)

	create_mode_event_autocmds()
	if enable_on_focus_events then
		create_focus_event_autocmds()
	end
end

return M
