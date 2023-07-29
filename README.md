# dap-info

`dap-info` is a lua plugin for Neovim to help show info from breakpoints created using [nvim-dap](https://github.com/mfussenegger/nvim-dap)

## Install

### with `lazy.nvim`

```lua
{
    'jonathan-elize/dap-info.nvim',
    dependencies = {
      "mfussenegger/nvim-dap",
    }
}
```

## Setup

```lua
require("dap-info").setup({})
```

Below is the default config, you can change it according to your needs.

```lua
require('persistent-breakpoints').setup{
  -- focu_id used for popup
  focus_id = "dap-info",
  -- options used for virtual text ui
  virt_text_opts = {
    namespace = "dap-info",
    prefix = "●",
    suffix = "",
    spacing = 4,
  },
}
```

## Usage

### **:DapInfoNextBp**

Goes to the next breakpoint in file and tries to reveal info about it if possible

### **:DapInfoPrevBp**

Goes to the previous breakpoint in file and tries to reveal info about it if possible

### **:DapInfoRevealBp**

Tries to reveal info about the breakpoint on the current line if possible

## Issue

- Seems to be a bug when trying to show the info for a breakpoint when using `DapInfoPrevBp` or `DapInfoNextBp` where the data won't show in a popup
