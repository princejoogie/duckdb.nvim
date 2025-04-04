local M = {}

M.valid_subcommands = { "open", "close", "first", "last", "next", "prev" }

M.default_state = {
	current_page = 0,
	total_rows = 0,
	rows_per_page = 50,
	current_file = nil,
	bufnr = nil,
}

M.state = vim.deepcopy(M.default_state)

--- @function update_buffer_title
--- Update the title of the buffer with current pagination information
--- @param buf number The buffer number to update
local function update_buffer_title(buf)
	local title = string.format(
		"CSV [Page %d/%d] (%d rows per page) - %s",
		M.state.current_page,
		math.ceil(M.state.total_rows / M.state.rows_per_page),
		M.state.rows_per_page,
		vim.fn.fnamemodify(M.state.current_file, ":t")
	)
	vim.api.nvim_buf_set_name(buf, title)
end

--- @function create_mappings
--- Create key mappings for the buffer
--- @param buf number The buffer number to create mappings for
local function create_mappings(buf)
	vim.keymap.set("n", "<Tab>", "f│zs", { buffer = buf })
	vim.keymap.set("n", "<S-Tab>", "F│zs", { buffer = buf })
end

--- @function fetch_data_for_page
--- Fetch data from DuckDB for the current page and update the buffer
--- @param buf number The buffer number to update with new data
function M.fetch_data_for_page(buf)
	local offset = (M.state.current_page - 1) * M.state.rows_per_page
	local cmd = string.format(
		"duckdb -c \"SELECT * FROM '%s' LIMIT %d OFFSET %d\"",
		M.state.current_file,
		M.state.rows_per_page,
		offset
	)

	vim.fn.jobstart(cmd, {
		stdout_buffered = true,
		on_stdout = function(_, data)
			if data then
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, data)
				update_buffer_title(buf)
			end
		end,
		on_stderr = function(_, data)
			if data and data[1] ~= "" then
				vim.notify(string.format("Error: %s", vim.inspect(data)), vim.log.levels.ERROR)
			end
		end,
	})
end

--- @function reset_cursor
--- Reset the cursor position to the top of the buffer
function M.reset_cursor()
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

--- @function first_page
--- Navigate to the first page of data
--- @param buf number The buffer number to update
function M.first_page(buf)
	M.state.current_page = 1
	M.fetch_data_for_page(buf)
	M.reset_cursor()
end

--- @function last_page
--- Navigate to the last page of data
--- @param buf number The buffer number to update
function M.last_page(buf)
	local max_pages = math.ceil(M.state.total_rows / M.state.rows_per_page)
	M.state.current_page = max_pages
	M.fetch_data_for_page(buf)
	M.reset_cursor()
end

--- @function next_page
--- Navigate to the next page of data
--- @param buf number The buffer number to update
function M.next_page(buf)
	local max_pages = math.ceil(M.state.total_rows / M.state.rows_per_page)
	if M.state.current_page < max_pages then
		M.state.current_page = M.state.current_page + 1
		M.fetch_data_for_page(buf)
	else
		vim.notify("Already at last page", vim.log.levels.WARN)
	end
	M.reset_cursor()
end

--- @function prev_page
--- Navigate to the previous page of data
--- @param buf number The buffer number to update
function M.prev_page(buf)
	if M.state.current_page > 1 then
		M.state.current_page = M.state.current_page - 1
		M.fetch_data_for_page(buf)
	else
		vim.notify("Already at first page", vim.log.levels.WARN)
	end
	M.reset_cursor()
end

--- @function close
--- Close the CSV display and clean up state
function M.close()
	vim.api.nvim_buf_delete(vim.api.nvim_get_current_buf(), { force = true })
	M.state = vim.deepcopy(M.default_state)
end

--- @function view_data
--- Display the CSV file in the current buffer with pagination
function M.view_data()
	local file_path = vim.fn.expand("%:p")

	if not file_path:match("^.+%.(csv)$") then
		vim.notify("Error: Current file is not a CSV file", vim.log.levels.ERROR)
		return
	end

	-- Create buffer and set options
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_set_option_value("wrap", false, { win = win })
	vim.api.nvim_win_set_buf(win, buf)

	-- Reset state for new file
	M.state.current_page = 1
	M.state.current_file = file_path
	M.state.bufnr = buf

	-- Get total rows synchronously
	local cmd = string.format("duckdb -c '.mode json' -c \"SELECT COUNT(*) FROM '%s'\"", file_path)
	local output = vim.system({ "sh", "-c", cmd }):wait()

	if output.code ~= 0 then
		vim.notify("Error getting row count: " .. (output.stderr or ""), vim.log.levels.ERROR)
		return
	end

	-- Parse JSON output
	local ok, result = pcall(vim.json.decode, output.stdout)
	if not ok or not result then
		vim.notify("Failed to parse row count JSON: " .. (result or "unknown error"), vim.log.levels.ERROR)
		return
	end

	M.state.total_rows = result[1]["count_star()"]
	if not M.state.total_rows then
		vim.notify("Failed to get row count from JSON", vim.log.levels.ERROR)
		return
	end

	create_mappings(buf)
	M.fetch_data_for_page(buf)
end

--- @function exec
--- Execute a subcommand for the CSV display
--- @param subcommand string The subcommand to execute (open|close|first|last|next|prev)
M.exec = function(subcommand)
	if not subcommand or subcommand == "" then
		vim.notify(
			"Please provide a subcommand. Valid options: " .. table.concat(M.valid_subcommands, ", "),
			vim.log.levels.WARN
		)
		return
	end

	if subcommand == "open" then
		M.view_data()
	elseif subcommand == "close" then
		M.close()
	elseif subcommand == "first" then
		M.first_page(M.state.bufnr)
	elseif subcommand == "last" then
		M.last_page(M.state.bufnr)
	elseif subcommand == "next" then
		M.next_page(M.state.bufnr)
	elseif subcommand == "prev" then
		M.prev_page(M.state.bufnr)
	else
		vim.notify(
			"Invalid subcommand: " .. subcommand .. ". Valid options: " .. table.concat(M.valid_subcommands, ", "),
			vim.log.levels.WARN
		)
	end
end

return M
