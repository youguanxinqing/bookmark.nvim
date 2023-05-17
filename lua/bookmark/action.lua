local db = require("bookmark.datastore")
local util = require("bookmark.util")

local bookmarks = db.bookmarks

local M = {}

function M.toggle()
	local bookmark = bookmarks.get()
	if bookmark == nil then
		bookmarks.create()
	else
		bookmarks.delete()
	end
end

function M.next()
	local bufnr = vim.api.nvim_get_current_buf()
	local group = "Bookmarks"
	local signs = vim.fn.sign_getplaced(bufnr, { group = group })
	local lnums = {}
	for _, sign in ipairs(signs[1].signs) do
		table.insert(lnums, sign.lnum)
	end

	if #lnums == 0 then
		print("No bookmarks")
		return
	end

	if #lnums > 0 then
		-- TODO: make sure these are sorted before we get here
		table.sort(lnums)
		if #lnums > 0 then
			local next_line = util.next_largest(util.get_current_line(), lnums)
			if next_line == nil then
				next_line = lnums[1]
			end
			vim.api.nvim_win_set_cursor(0, { next_line, 0 })
			vim.api.nvim_command("normal! zz")
		else
			print("No bookmarks")
		end
	else
		print("No bookmarks")
	end
end

function M.previous()
	local bufnr = vim.api.nvim_get_current_buf()
	local group = "Bookmarks"
	local signs = vim.fn.sign_getplaced(bufnr, { group = group })
	local lnums = {}
	for _, sign in ipairs(signs[1].signs) do
		table.insert(lnums, sign.lnum)
	end

	if #lnums == 0 then
		print("No bookmarks")
		return
	end

	if #lnums > 0 then
		-- TODO: make sure these are sorted before we get here
		table.sort(lnums)
		if #lnums > 0 then
			local next_line = util.next_smallest(util.get_current_line(), lnums)
			if next_line == nil then
				next_line = lnums[#lnums]
			end
			vim.api.nvim_win_set_cursor(0, { next_line, 0 })
			vim.api.nvim_command("normal! zz")
		else
			print("No bookmarks")
		end
	else
		print("No bookmarks")
	end
end

function M.next_prj()
	print("stub")
end

function M.previous_prj()
	print("stub")
end

function M.list()
	print("stub")
end

function M.clear_buffer()
	print("stub")
end

function M.clear_project()
	print("stub")
end

function M.annotate()
	print("stub")
end

function M.change_icon()
	print("stub")
end

function M.mark_file()
	print("stub")
end

function M.mark_search()
	-- usecase search for function mark lines, search is free can move between functions
	local search_term = vim.fn.getreg("/")
	local line_numbers = {}
	local line_number = vim.fn.search(search_term, "cn")

	while line_number ~= 0 do
		table.insert(line_numbers, line_number)
		line_number = vim.fn.search(search_term, "cn")
	end

	for _, line in ipairs(line_numbers) do
		print(line)
	end
end

function M.export_buf_annotations()
	print("stub")
end

function M.export_prj_annotations()
	print("stub")
end

return M
