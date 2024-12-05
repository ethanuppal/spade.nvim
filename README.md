# spade.nvim

Neovim language support for [Spade](https://spade-lang.org).

![Example usage of the plugin](./assets/spade-github-dark.gif)

## Contents

- [Features](#features)
- [Requirements](#requirements)
- [Install](#install)
- [Help](#help)

<a name="features"></a>

## Features

- Syntax highlighting
- Go-to-definition
- Code completion
- Hover
- Jump to `swim.toml` (<https://github.com/ethanuppal/spade.nvim/issues/2>)
- Autoformatting with [spadefmt](http://github.com/ethanuppal/spadefmt) (<https://github.com/ethanuppal/spade.nvim/issues/3>)
- Builtin keybinds? (<https://github.com/ethanuppal/spade.nvim/issues/7>)

<a name="requirements"></a>

## Requirements

- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [query files](https://gitlab.com/spade-lang/spade-vim)

Depending on what package manager you're using, you may not need to worry about this (see [Install](#install)).

<a name="install"></a>

## Install

> [!NOTE]
> This section assumes a Unix-like operating system.

First, you'll want to grab the Spade LSP (you might need to [install
rust](https://www.rust-lang.org/tools/install)):

```sh
cargo install --locked --git https://gitlab.com/spade-lang/spade-language-server
```

**Recommended**: Alternatively, you can also build the LSP yourself with changes if it's not up-to-date with the
latest in Spade, as I have done:

```sh
cargo install --locked --git https://gitlab.com/ethanuppal/spade-language-server
```

Then, install the plugin with your preferred package manager.
Here's how it would look like if you're using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ "ethanuppal/spade.nvim" }
```

You can supply configuration with the optional `opts` field, as in

```lua
{
    "ethanuppal/spade.nvim",
    opts = {
        lsp_command = "spade-language-server"
    }
}
```

Note that [lazy.nvim](https://github.com/folke/lazy.nvim) will automatically call `require("spade").setup({ ... })` for you as well as install the required dependencies.
You may have to do them manually with another package manager.

<a name="help"></a>

## Help

### Why isn't the LSP activating? I checked with `top` (or similar) and don't see the LSP process

Make sure you have a [`swim.toml`](https://docs.spade-lang.org/swim_project_configuration/config__Config.html) somewhere up your tree -- the LSP will activate in that directory.
