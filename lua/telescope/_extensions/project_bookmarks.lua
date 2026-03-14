local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local bookmarks_db = require("bookmark.datastore.bookmark_tbl")
local files_db = require("bookmark.datastore.file_tbl")

return function(opts)
	opts = opts or {}
	local path = vim.fn.getcwd()
	local all_files = files_db.get_all()
	local results = {}
	for _, file in ipairs(all_files) do
		local file_bookmarks = bookmarks_db.get_all_by_file_id(file.id)
		for _, bm in ipairs(file_bookmarks) do
			local ok, line_text = pcall(function()
				local bufnr = vim.fn.bufadd(path .. file.path)
				vim.fn.bufload(bufnr)
				return vim.api.nvim_buf_get_lines(bufnr, bm.lnum - 1, bm.lnum, false)[1] or ""
			end)
			table.insert(results, {
				lnum = bm.lnum,
				sign = bm.sign,
				annotation = bm.annotation or "",
				line_text = ok and line_text or "",
				path = path .. file.path,
				rel_path = file.path,
			})
		end
	end
	table.sort(results, function(a, b)
		if a.path ~= b.path then return a.path < b.path end
		return a.lnum < b.lnum
	end)
	pickers.new(opts, {
		prompt_title = "Project Bookmarks",
		sorter = conf.generic_sorter(opts),
		previewer = conf.grep_previewer(opts),
		finder = finders.new_table({
			results = results,
			entry_maker = function(entry)
				local ann = entry.annotation ~= "" and ("[" .. entry.annotation .. "]  ") or ""
				local display = string.format("%s:%d %s  %s%s", entry.rel_path:sub(2), entry.lnum, entry.sign, ann, entry.line_text)
				return {
					value = entry,
					display = display,
					ordinal = entry.rel_path .. " " .. tostring(entry.lnum) .. " " .. entry.line_text,
					path = entry.path,
					lnum = entry.lnum,
				}
			end,
		}),
	}):find()
end
