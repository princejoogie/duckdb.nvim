local M = {}

--- @function setup
--- Setup the plugin with the provided options
--- @param options table The options to use
function M.setup(options)
	require("duckdb.config").setup(options)
	require("duckdb.cmd").create_user_command()
end

return M
