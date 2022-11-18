local M = {}

local auGroupName = "IMSelsetAutoCMDs"
local switchIMCommands = {}

local default_configs = {
	-- im-select command, maybe the path to the executable `im-select`.
  -- default value : "im-select".
	imselectCmd = "im-select",
	-- default input method neovim modes other than insert mode.
  -- default value for macOS: "com.apple.keylayout.ABC".
  -- defalt value for Windows: "1033".
	defaultIM = (vim.fn.has('win32') == 1) and "1033" or "com.apple.keylayout.ABC",
	-- enable or disable switch input method automatically.
	autoSwitch = true,
}

local imselectCmd = default_configs.imselectCmd
local defaultIM = default_configs.defaultIM
local autoSwitch = default_configs.autoSwitch

local function obtain_current_im()
	return vim.trim(vim.fn.system({ imselectCmd }))
end

local function swith_im(im)
	if switchIMCommands[im] == nil then
		switchIMCommands[im] = "silent !"..imselectCmd.." ".. im
	end
	vim.cmd(switchIMCommands[im])
end

function M.config(opts)
	-- set configs
	if type(opts) == "table" then
		imselectCmd = opts.imselectCmd or imselectCmd
		defaultIM = opts.defaultIM or defaultIM
		autoSwitch = opts.autoSwitch or autoSwitch
	end
end

local reservedIM = nil
local function creat_im_select_autocmds()
	vim.api.nvim_create_augroup(auGroupName, {clear = true})

	-- Leave insert mode or enter Vim, obtain current IM and swith IM to default
	vim.api.nvim_create_autocmd({ "InsertLeave", "VimEnter" }, {
		group = auGroupName,
		callback = function()
			reservedIM = obtain_current_im()
			if reservedIM ~= defaultIM then
				swith_im(defaultIM)
			end
		end,
	})

	-- Enter insert mode, swith IM back to the obtained IM before
	vim.api.nvim_create_autocmd({ "InsertEnter", "VimLeave" }, {
		group = auGroupName,
		callback = function()
			swith_im(reservedIM)
		end,
	})

	-- Nvim lost focus, switch to obtained IM if in normal mode, otherwise do nothing
	vim.api.nvim_create_autocmd({ "FocusLost" }, {
		group = auGroupName,
		callback = function()
			local currentMode = vim.fn.mode()
			if currentMode == "n" then
				swith_im(reservedIM)
			end
		end,
	})

	-- Nvim got focus, switch to the default IM if in normal mode, otherwise do nothing
	vim.api.nvim_create_autocmd({ "FocusGained" }, {
		group = auGroupName,
		callback = function()
			local currentMode = vim.fn.mode()
			if currentMode == "n" then
				swith_im(defaultIM)
			end
		end,
	})
end

function M.toggle()
	if autoSwitch == true then
		autoSwitch = false
		vim.api.nvim_clear_autocmds({group = auGroupName})
	else
		autoSwitch = true
		creat_im_select_autocmds()
	end
end

-- Command to turn on/off switching switch input method automatically.
vim.api.nvim_create_user_command("IMSelectToggle", M.toggle, {})

function M.setup(opts)
	if vim.fn.has("macunix") ~= 1 and vim.fn.has("win32") ~= 1 then
		vim.api.nvim_err_writeln([[neovim-im-select only works on Windows or macOS.]])
		return
	end
	M.config(opts)
	if vim.fn.executable(imselectCmd) ~= 1 then
		vim.api.nvim_err_writeln(
			[[neovim-im-select requires `im-select` to be installed, repo url: https://github.com/daipeihust/im-select]]
		)
		return
	end
	creat_im_select_autocmds()
end

return M
