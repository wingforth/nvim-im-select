# nvim-im-select

Switch Input Method automatically according to Neovim edit mode, Nevim lost or got focus, and exiting Neovim.  
The main intention is that when neovim enters normal mode, the input method will always switch to the English IM (the default IM we set). When Neovim enters insert mode, or Neovim lost focus, the input method will switch back to the previous state that entering normal mode last.

- When entering Neovim or leaving insert mode, reserve current IM, and switch to default IM.
- when exiting Neovim or Entering insert mode, switch to the reserved IM.
- When Neovim lost focus and Neovim is in normal mode, switch to the reserved IM.
- when Neovim got focus and Neovim is in normal mode, switch to default IM.

## Requirements

Using Neovim on Windows or macOS.  
[im-select](https://github.com/daipeihust/im-select) should be installed.

## Install

Install with [packer](https://github.com/wbthomason/packer.nvim):

```lua
use "wingforth/nvim-im-select"
```

## Setup

The setup function accepts a dictionary that contains options as argument.  
There are three options that can be specified:

- `im_select_cmd`: the im-select command, maybe the path to the executable `im-select`.
- `default_im`: the default input method for neovim modes other than insert mode.
- `enable_on_focus_events`: enable or disable switch input method automatically on FocusLost and FocusGained events. If you have set up other ways to switch IM among different windows/applications, you may want to set this option to `false`. Default `true`.  

e.g.

```lua
require("im_select").setup({
    -- im-select command, maybe the path to the executable `im-select`.
    -- default value : "im-select"
    im_select_cmd= "D:\\Tools\\im-select.exe",
    -- default input method for normal mode or others except insert.
    -- default value for macOS: "com.apple.keylayout.ABC".
    -- defalt value for Windows: "1033"
    default_im = "1033",
	-- enable or disable switch input method automatically on FocusLost and FocusGained events.
    -- disable by setting this option to false/0, or any other to enable.
    -- if you have set up other ways to switch IM among different windows/applications, you may want to set this option to false. 
	-- default value is true.
	enable_on_focus_events = true,
})
```

If the default values works for you, simply setup without passing any parameters.

```lua
require("im_select").setup()
```

## Global variables

A global variable is used to check whether it is enabled on FocusLost and FocusGained events:

- `im_select_enable_on_focus_events`

## Commands

There is a command to turn on/off switching input method automatically on FocusLost and FocusGained events:

- `:IMSelectFocusEventsToggle`

## Known issues

Switching IM on FocusLost and FocusGained events, Microsoft Pinyin IM can't distinguish between Chinese and English mode.
