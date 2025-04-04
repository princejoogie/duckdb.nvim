local M = {}

function M.setup(_options)
	require("duckdb.cmd").create_user_command()
end

return M
