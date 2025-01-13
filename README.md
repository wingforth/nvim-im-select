# nvim-im-select

Switch Input Method automatically according to Neovim mode, Nevim lost or got focus, and exiting Neovim.  
The main intention is that when neovim enters Normal, Visual, Cmdline and Ex modea, the input method will always switch to the English IM (the default IM we set). When Neovim enters Insert and Replace mode, or Neovim lost focus, the input method will switch back to the previous state that saved when leaving these modes last time.

- When entering Neovim or leaving insert mode, reserve current IM, and switch to default IM.
- when exiting Neovim or Entering insert mode, switch to the previous IM.
- When Neovim lost focus and Neovim is in normal mode, switch to the previous IM.
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
There are five options that can be specified:

1. `im_select_cmd`: the `im-select` command, the path to the executable `im-select`.
2. `default_im`: the default input method in Normal, Visual, Cmdline and Ex modes.
3. `insert_im`: the input method in Insert and Replace modes.
4. `enable_im_select`: enable or disable plugin neovim-im-select.
5. `enable_on_focus_events`: enable or disable switch input method automatically on FocusLost and FocusGained events. If you have set to switch IM among different windows/applications by other ways, you should set it to `false`. Default `false`.  

e.g.

```lua
require("im_select").setup({
    -- Option: [string] im_select_cmd
    -- Command of `im-select`, the path to the executable `im-select`.
    -- Default value : "im-select"
    im_select_cmd= "D:\\Tools\\im-select.exe",

    -- Option: [string] default_im
    -- Default input method for normal mode or others except Insert and Replace.
    -- Default value for macOS: "com.apple.keylayout.ABC".
    -- Defalt value for Windows: "1033"
    default_im = "1033",

    -- Option: [string] insert_im
    -- The input method specified for Insert, Replace mode. 
    -- If it is set, always switch to it when entering Insert, Replace mode.
    -- If it is not set, the insert mode IM will be auto obtained and saved IM when leaving Insert, Replace mode.
    -- Default value: nil.
    insert_im = nil,

    -- Option: [boolean] enable_im_select
    -- Whether enable switching input method automatically.
    -- Set it to false/0 to disable it, or any other value to enable it.
    -- Default value: true.
    enable_im_select = true,

    -- Option: [boolean] enable_on_focus_events
    -- enable or disable switch input method automatically on FocusLost and FocusGained events.
    -- disable by setting this option to false/0, or any other to enable.
    -- If you have set to switch IM among different windows/applications by other ways, you should set it to false. 
    -- Note that the IM of external applications is the same as the IM of Insert mode.
    -- Default value: false.
    enable_on_focus_events = false,
})
```

If the default values works for you, simply setup without passing any parameters.

```lua
require("im_select").setup()
```

## Commands

There are two commands:

1. `:ImSelectToggle`  
    Command `ImSelectToggle` is used to enable/disabled pulgin neovim-im-select.
2. `:ImSelectFocusEventToggle`  
    Command `ImSelectFocusEventToggle` is used to turn on/off switching input method automatically on FocusLost and FocusGained events.

## Known issues

On Windows OS, if Neovim lost focus by clicking the taskbar or desktop with the mouse, FocusLost and FocusGained event autocmds will not be triggered correctly.
