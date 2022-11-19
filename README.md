# nvim-im-select

Switch Input Method automatically according to Neovim edit mode, Nevim lost or got focus, and exiting Neovim.  
The main intention is that when neovim enters normal mode, the input method will always switch to the English IM (the default IM we set). When Neovim enters insert mode, or Neovim lost focus, the input method will switch back to the previous state that entering normal mode last.

- When entering Neovim or leaving insert mode, reserve current IM, and switch to default IM.
- when exiting Neovim or Entering insert mode, switch to the reserved IM.
- When Neovim lost focus and Neovim is in normal mode, switch to the reserved IM.
- when Neovim got focus and Neovim is in normal mode, switch to default IM.

## Requirements

Using Neovim  on Windows or macOS.  
[im-select](https://github.com/daipeihust/im-select) should be installed.

## Install

Install with [packer](https://github.com/wbthomason/packer.nvim):

```lua
use "wingforth/nvim-im-select"
```

## Setup

The setup function accepts a dictionary that contains options as argument.  
There are four options that can be specified:

- `imselectCmd`: the im-select command, maybe the path to the executable `im-select`.
- `defaultIM`: the default input method for neovim modes other than insert mode.
- `modeAutoSwitch`: enable or disable switch input method automatically according to edit mode. `true` or `false`, default `true`, enabled.
- `focusAutoSwitch`: enable or disable switch input method automatically for FocusLost and FocusGained events. `true` or `false`, default `false`, diabled.

e.g.

```lua
require("im_select").setup({
    -- im-select command, maybe the path to the executable `im-select`.
    -- default value : "im-select"
    imselectCmd = "D:\\Tools\\im-select.exe",
    -- default input method for normal mode or others except insert.
    -- default value for macOS: "com.apple.keylayout.ABC".
    -- defalt value for Windows: "1033"
    defaultIM = "1033",
	-- enable or disable switch input method automatically according to edit mode.
	modeAutoSwitch = true,
	-- enable or disable switch input method automatically for FocusLost and FocusGained events.
	focusAutoSwitch = false,
})
```

If the default values wors for you, simply setup without passing any parameters.

```lua
require("im_select").setup()
```

## Commands

There are two commands to turn on/off switching input method automatically:

- `:IMSelectModeToggle`: turn on/off switching input method automatically according to edit mode.
- `:IMSelectFocusToggle`: turn on/off switching input method automatically for FocusLost and FocusGained events.

## Known issues

Switching IM for FocusLost and FocusGained events, Microsoft Pinyin IM can't distinguish between Chinese and English mode.
