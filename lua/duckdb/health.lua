local M = {}
local is_duckdb_executable = function()
	return vim.fn.executable("duckdb") == 1
end

M.check = function()
	vim.health.start("DuckDB.nvim")
	if is_duckdb_executable() then
		vim.health.ok("`duckdb` CLI tool is available")
	else
		vim.health.error([[`duckdb` CLI tool is not available. 
       Ensure that it is installed and can be found via your `$PATH`.]])
	end
end
return M
