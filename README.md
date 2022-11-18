# nvim-im-select
 Switch Input Method automatically according to Neovim edit mode.

## Requirements
 Neovim 0.8+, on Windows or macOS.  
 [im-select](https://github.com/daipeihust/im-select) should be installed. 

## Install
 
 Install with [packer](https://github.com/wbthomason/packer.nvim):  

```lua
use "wingforth/nvim-im-select"
```

## Config
 There are three options that can be specified:
 - `imselectCmd`: the im-select command, maybe the path to the executable `im-select`. 
 - `defaultIM`: the default input method for neovim modes other than insert mode.  
 - `autoSwitch`: enable or disable switch input method automatically. Default true, enabled.

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
    --  to automatically switch input methods.
    autoSwitch = true,
})
```

If the default values wors for you, simply setup without passing parameters.

```lua
require("im_select").setup()
```

## Commands

`:IMSelectToggle` Turn on/off switching input method automatically according to the mode.
