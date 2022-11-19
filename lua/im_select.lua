local M = {}

local modeAugroup = "IMSelsetModeAutocmd"
local focusAugroup = "IMSelsetFocusAutocmd"

local default_configs = {
	-- im-select command, maybe the path to the executable `im-select`.
  	-- default value : "im-select".
	imselectCmd = "im-select",
	-- default input method neovim modes other than insert mode.
  	-- default value for macOS: "com.apple.keylayout.ABC".
  	-- defalt value for Windows: "1033".
	defaultIM = (vim.fn.has('win32') == 1) and "1033" or "com.apple.keylayout.ABC",
	-- enable or disable switch input method automatically according to edit mode.
	modeAutoSwitch = true,
	-- enable or disable switch input method automatically for FocusLost and FocusGained events.
	focusAutoSwitch = false,
}

local imselectCmd = default_configs.imselectCmd
local defaultIM = default_configs.defaultIM
local modeAutoSwitch = default_configs.modeAutoSwitch
local focusAutoSwitch = default_configs.focusAutoSwitch

local switchIMCommands = {}
local reservedIM = nil

local obtain_current_im = function()
	return vim.trim(vim.fn.system({ imselectCmd }))
end

local swith_im = function(im)
	if switchIMCommands[im] == nil then
		switchIMCommands[im] = "silent !"..imselectCmd.." "..im
	end
	vim.cmd(switchIMCommands[im])
end

local set_configs = function(opts)
	if opts.imselectCmd ~= nil then
		imselectCmd = opts.imselectCmd
	end

	if opts.defaultIM ~= nil then
		defaultIM = opts.defaultIM
	end

	if opts.modeAutoSwitch == true or opts.modeAutoSwitch == false then
		modeAutoSwitch = opts.modeAutoSwitch
	end
	
	if opts.focusAutoSwitch == true or opts.focusAutoSwitch == false then
		focusAutoSwitch = opts.focusAutoSwitch
	end
end

local creat_mode_autocmds = function()
	vim.api.nvim_create_augroup(modeAugroup, {clear = true})

	-- Leave insert mode or enter Vim, obtain current IM and swith IM to default
	vim.api.nvim_create_autocmd({ "InsertLeave", "VimEnter" }, {
		group = modeAugroup,
		callback = function()
			reservedIM = obtain_current_im()
			if reservedIM ~= defaultIM then
				swith_im(defaultIM)
			end
		end,
	})

	-- Enter insert mode, swith IM back to the obtained IM before
	vim.api.nvim_create_autocmd({ "InsertEnter", "VimLeave" }, {
		group = modeAugroup,
		callback = function()
			swith_im(reservedIM)
		end,
	})
end

local creat_focus_autocmds = function()
	vim.api.nvim_create_augroup(focusAugroup, {clear = true})

	-- Nvim lost focus, switch to obtained IM if in normal mode, otherwise do nothing
	vim.api.nvim_create_autocmd({ "FocusLost" }, {
		group = focusAugroup,
		callback = function()
			local currentMode = vim.fn.mode()
			if currentMode == "n" then
				swith_im(reservedIM)
			end
		end,
	})

	-- Nvim got focus, switch to the default IM if in normal mode, otherwise do nothing
	vim.api.nvim_create_autocmd({ "FocusGained" }, {
		group = focusAugroup,
		callback = function()
			local currentMode = vim.fn.mode()
			if currentMode == "n" then
				swith_im(defaultIM)
			end
		end,
	})
end

local mode_toggle = function()
	if modeAutoSwitch == true then
		modeAutoSwitch = false
		vim.api.nvim_clear_autocmds({group = modeAugroup})
	else
		modeAutoSwitch = true
		creat_mode_autocmds()
	end
end

local focus_toggle = function()
	if focusAutoSwitch == true then
		focusAutoSwitch = false
		vim.api.nvim_clear_autocmds({group = focusAugroup})
	else
		focusAutoSwitch = true
		creat_focus_autocmds()
	end
end

-- Command to turn on/off switching switch input method automatically.
vim.api.nvim_create_user_command("IMSelectModeToggle", mode_toggle, {})
vim.api.nvim_create_user_command("IMSelectFocusToggle", focus_toggle, {})

M.setup = function(opts)
	if vim.fn.has("macunix") ~= 1 and vim.fn.has("win32") ~= 1 then
		vim.api.nvim_err_writeln([[neovim-im-select only works on Windows or macOS.]])
		return
	end

	if type(opts) == "table" then
		set_configs(opts)
	end

	if vim.fn.executable(imselectCmd) ~= 1 then
		vim.api.nvim_err_writeln(
			[[neovim-im-select requires `im-select` to be installed, repo url: https://github.com/daipeihust/im-select]]
		)
		return
	end

	if modeAutoSwitch == true then
		creat_mode_autocmds()
	end

	if focusAutoSwitch == true then
		creat_focus_autocmds()
	end
end

return M
