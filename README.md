# duckdb.nvim

A Neovim plugin for interacting with DuckDB databases.

https://github.com/user-attachments/assets/a74d2c7d-0baf-404a-8c18-ad17b7461622

## Prerequisites

- [DuckDB CLI](https://duckdb.org/) installed and available in your `$PATH`

## Installation

Install the plugin using your preferred package manager. For example, with [vim-plug](https://github.com/junegunn/vim-plug):

```lua
{
    "princejoogie/duckdb.nvim",
    config = function()
        require("duckdb").setup()
    end,
}
```

## Usage

The plugin provides a `:DuckView` command with several subcommands for interacting with CSV files:

| Subcommand | Description                                                           |
| ---------- | --------------------------------------------------------------------- |
| `open`     | Open the current CSV file in a display buffer with pagination support |
| `close`    | Close the CSV display buffer and clean up state                       |
| `first`    | Jump to the first page of data                                        |
| `last`     | Jump to the last page of data                                         |
| `next`     | Move to the next page of data                                         |
| `prev`     | Move to the previous page of data                                     |

The display buffer includes these keybindings:

- `<Tab>` - Move to next column
- `<S-Tab>` - Move to previous column

The buffer title shows the current pagination information in the format:
`CSV [Page X/Y] (Z rows per page) - filename`

You can navigate through pages using either the command subcommands or the keybindings.
