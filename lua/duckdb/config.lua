--- @class duckdb.Config

local M = {}

M._default_config = {
	rows_per_page = 50,
}

M.config = vim.deepcopy(M._default_config)

--- @function setup
--- Setup the plugin with the provided config
--- @param config table The config to use
function M.setup(config)
	M.config = vim.tbl_deep_extend("force", M.config, config or {})
end

return M
