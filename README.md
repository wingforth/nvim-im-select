# nvim-im-select

Some Neovim users may require different input methods when Neovim is in different modes. Such as users from some Asian countries, they want the input method to switch to the English language IM when neovim enters Normal, Visual, Cmdline or Ex mode, and switch back to the local language IM When Neovim enters Insert or Replace mode.

The main intention of this plugin is to automatically switch the input method when neovim mode changed, Neovim lost or got focus, entering and leaving Neovim. The IM in normal mode called `default IM`, auto switch to it when entering Normal, Cmdline or Ex mode. The IM in insert mode called `insert IM`, auto switch to it when entering Insert and Replace mode.

- When entering Neovim and leaving Insert or Replace mode, obtain and save current IM as `insert IM`, then switch to `default IM`.
- when exiting Neovim and Entering Insert or Replace mode, switch to the `insert IM`.
- When Neovim is in normal mode and lost focus, switch to the `insert IM`.
- when Neovim is in normal mode and got focus, switch to `default IM`.

## Requirements

1. Using Neovim on Windows or macOS platform.  
2. [im-select](https://github.com/daipeihust/im-select) should be installed.

## Installation and Setup

Install plugin with your preferred plugin manager.

- [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
    "wingforth/nvim-im-select",
    config = function() 
        require("im_select").setup{ 
            -- Your configuration 
        } 
    end
}
```

- [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "wingforth/nvim-im-select",
    lazy = false,
    priority = 1000,
    config = function() 
        require("im_select").setup {
            -- Your configuration
        }
    end
}
```

## Configuration

You can customize the configuration when calling `setup()` function.
The `setup()` function accepts a dictionary that contains options as argument.  
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
    -- Default value for Windows: "1033"
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

If the default values works for you, just simply setup without passing any parameters.

```lua
require("im_select").setup()
```

## Commands

There are two commands:

1. `:ImSelectToggle`  
    Command `ImSelectToggle` is used to enable/disabled plugin neovim-im-select.
2. `:ImSelectFocusEventToggle`  
    Command `ImSelectFocusEventToggle` is used to turn on/off switching input method automatically on FocusLost and FocusGained events.

## Known issues

On Windows OS, if Neovim lost focus by clicking the taskbar or desktop with the mouse, FocusLost and FocusGained event autocmds will not be triggered correctly.
