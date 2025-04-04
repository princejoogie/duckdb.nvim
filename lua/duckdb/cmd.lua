local valid_subcommands = require("duckdb.core").valid_subcommands
local exec = require("duckdb.core").exec

local M = {}

-- Create the user command
M.create_user_command = function()
	vim.api.nvim_create_user_command("DuckView", function(opts)
		exec(opts.args)
	end, {
		nargs = 1,
		complete = function(_, _, _)
			return valid_subcommands
		end,
		desc = "CSV display commands (open|close|first|last|next|prev)",
	})
end

return M
