local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local bookmarks_db = require("bookmark.datastore.bookmark_tbl")
local files_db = require("bookmark.datastore.file_tbl")

return function(opts)
	opts = opts or {}
	local path = vim.fn.getcwd()
	local file = files_db.get()
	local results = {}
	if file ~= nil then
		for _, bm in ipairs(bookmarks_db.get_all_file()) do
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
			})
		end
		table.sort(results, function(a, b) return a.lnum < b.lnum end)
	end
	pickers.new(opts, {
		prompt_title = "Buffer Bookmarks",
		sorter = conf.generic_sorter(opts),
		previewer = conf.grep_previewer(opts),
		finder = finders.new_table({
			results = results,
			entry_maker = function(entry)
				local ann = entry.annotation ~= "" and ("[" .. entry.annotation .. "]  ") or ""
				local display = string.format("%4d %s  %s%s", entry.lnum, entry.sign, ann, entry.line_text)
				return {
					value = entry,
					display = display,
					ordinal = tostring(entry.lnum) .. " " .. entry.line_text,
					path = entry.path,
					lnum = entry.lnum,
				}
			end,
		}),
	}):find()
end
