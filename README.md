# duckdb.nvim

> **WARNING**: This project is under heavy development and not ready for general use yet!
> Some features may be incomplete or unstable. Use with caution.

A Neovim plugin for interacting with DuckDB databases.

https://github.com/user-attachments/assets/a74d2c7d-0baf-404a-8c18-ad17b7461622

## Prerequisites

- [DuckDB CLI](https://duckdb.org/) installed and available in your `$PATH`

## Installation

Install the plugin using your preferred package manager. For example, with [lazy](https://lazy.folke.io/):

```lua
{
  "princejoogie/duckdb.nvim",
  opts = {}
}
```

## Configuration

Here's an example configuration for the plugin:

```lua
return {
  dir = "princejoogie/duckdb.nvim",
  ft = { "csv" },
  opts = {
    rows_per_page = 50,
  },
  keys = {
    { "<leader>po", "<cmd>DuckView open<cr>", desc = "DuckView open" },
    { "<leader>pc", "<cmd>DuckView close<cr>", desc = "DuckView close" },
    { "<leader>pn", "<cmd>DuckView next<cr>", desc = "DuckView Next page", ft = "duck_view" },
    { "<leader>pp", "<cmd>DuckView prev<cr>", desc = "DuckView Previous page", ft = "duck_view" },
    { "<leader>pf", "<cmd>DuckView first<cr>", desc = "DuckView First page", ft = "duck_view" },
    { "<leader>pl", "<cmd>DuckView last<cr>", desc = "DuckView Last page", ft = "duck_view" },
                                                                       -- `ft` is optional to only apply to duck_view buffers
  },
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
