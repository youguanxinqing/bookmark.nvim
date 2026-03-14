local db = require("bookmark.datastore")
local util = require("bookmark.util")
local config = require("bookmark.config")

local bookmarks = db.bookmarks
local files = db.files
local projects = db.projects

local M = {}

local function apply_annotation(bookmark, default_text)
	local existing = default_text ~= nil and default_text or (bookmark.annotation or "")
	local annotation = vim.fn.input({ prompt = "Annotation: ", default = existing, cancelreturn = "\0CANCEL\0" })
	vim.cmd("redraw")
	vim.cmd("echo ''")
	if annotation == "\0CANCEL\0" then return end
	bookmarks.set_annotation(bookmark.id, annotation)
	local ns = vim.api.nvim_create_namespace("bookmark_annotations")
	local bufnr = vim.api.nvim_get_current_buf()
	local lnum0 = vim.api.nvim_win_get_cursor(0)[1] - 1
	for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, ns, {lnum0, 0}, {lnum0, -1}, {})) do
		vim.api.nvim_buf_del_extmark(bufnr, ns, mark[1])
	end
	if annotation ~= "" then
		vim.api.nvim_buf_set_extmark(bufnr, ns, lnum0, 0, {
			virt_text = {{ "  " .. annotation, "Comment" }}, virt_text_pos = "eol"
		})
	end
end

function M.toggle()
	-- TODO: filemark should have it's own group
	-- check if filemark on line, delete and replace with bookmark
	local bookmark = bookmarks.get()
	if bookmark == nil then
		bookmarks.create()
		local new_bookmark = bookmarks.get_full()
		if new_bookmark then
			apply_annotation(new_bookmark, "")
		end
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

function M.next_file()
	local file_list = files.get_all_marked()

	-- TODO: in future jump to file mark in current buffer if exists
	if #file_list == 0 or #file_list == 1 then
		print("No filemarks")
		return
	end

	table.sort(file_list, function(a, b)
		return a.sign_id < b.sign_id
	end)

	local project_path = vim.fn.getcwd()
	local filepath = vim.fn.expand("%:p")
	local relative_file_path = util.trim_prefix(filepath, project_path)

	local current_sign_id = nil
	local other_sign_ids = {}

	for i = #file_list, 1, -1 do
		local item = file_list[i]
		if item.path == relative_file_path then
			current_sign_id = item.sign_id
			table.remove(file_list, i)
		else
			table.insert(other_sign_ids, item.sign_id)
		end
	end

	local next_file_sign_id = nil

	if current_sign_id == nil then
		next_file_sign_id = file_list[1].sign_id
	else
		next_file_sign_id = util.next_largest(current_sign_id, other_sign_ids)
	end

	if next_file_sign_id == nil then
		next_file_sign_id = file_list[1].sign_id
	end

	local next_file = nil
	for i = #file_list, 1, -1 do
		local item = file_list[i]
		if item.sign_id == next_file_sign_id then
			next_file = item
		end
	end

	vim.api.nvim_command("edit " .. next_file.projects .. next_file.path)
	vim.api.nvim_command("normal! " .. next_file.lnum .. "G")
	vim.api.nvim_command("normal! zz")
end

function M.previous_file()
	local file_list = files.get_all_marked()

	-- TODO: in future jump to file mark in current buffer if exists
	if #file_list == 0 or #file_list == 1 then
		print("No filemarks")
		return
	end

	table.sort(file_list, function(a, b)
		return a.sign_id < b.sign_id
	end)

	local project_path = vim.fn.getcwd()
	local filepath = vim.fn.expand("%:p")
	local relative_file_path = util.trim_prefix(filepath, project_path)

	local current_sign_id = nil
	local other_sign_ids = {}

	for i = #file_list, 1, -1 do
		local item = file_list[i]
		if item.path == relative_file_path then
			current_sign_id = item.sign_id
			table.remove(file_list, i)
		else
			table.insert(other_sign_ids, item.sign_id)
		end
	end

	local next_file_sign_id = nil

	if current_sign_id == nil then
		next_file_sign_id = file_list[#file_list].sign_id
	else
		next_file_sign_id = util.next_smallest(current_sign_id, other_sign_ids)
	end

	if next_file_sign_id == nil then
		next_file_sign_id = file_list[#file_list].sign_id
	end

	local next_file = nil
	for i = #file_list, 1, -1 do
		local item = file_list[i]
		if item.sign_id == next_file_sign_id then
			next_file = item
		end
	end

	vim.api.nvim_command("edit " .. next_file.projects .. next_file.path)
	vim.api.nvim_command("normal! " .. next_file.lnum .. "G")
	vim.api.nvim_command("normal! zz")
end

function M.list_buffer_ll()
	-- do it for the loclist as well
	print("stub")
end

function M.list_buffer_qf()
	vim.fn.setqflist({}, "r")
	-- local bufnr = vim.api.nvim_get_current_buf()
	-- TODO: also handle project wide bookmarks
	local bookmark_list = bookmarks.get_all_file()
	local qf_list = {}
	local path = vim.fn.getcwd()

	for _, item in ipairs(bookmark_list) do
		-- Open the file in a buffer and get the line text
		local file = files.get_by_id(item.files)
		local bufnr = vim.fn.bufadd(path .. file.path)
		vim.fn.bufload(bufnr)
		local line_text = vim.api.nvim_buf_get_lines(bufnr, item.lnum - 1, item.lnum, false)[1]
		local ann = (item.annotation and item.annotation ~= "") and ("[" .. item.annotation .. "]  ") or ""
		local text = item.sign .. "  " .. ann .. line_text
		table.insert(qf_list, { filename = path .. file.path, lnum = item.lnum, text = text })
	end
	vim.api.nvim_command("copen")

	vim.fn.setqflist(qf_list)
end

function M.clear_buffer()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.fn.sign_unplace("Bookmarks", { buffer = bufnr })
	local ns = vim.api.nvim_create_namespace("bookmark_annotations")
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	files.delete()
end

function M.clear_project()
	vim.fn.sign_unplace("Bookmarks")
	local ns = vim.api.nvim_create_namespace("bookmark_annotations")
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) then
			vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
		end
	end
	projects.delete()
end

function M.annotate()
	local bookmark = bookmarks.get_full()
	if bookmark == nil then print("No bookmark on current line"); return end
	apply_annotation(bookmark)
end

function M.list_project_qf()
	vim.fn.setqflist({}, "r")
	local path = vim.fn.getcwd()
	local all_files = files.get_all()
	local qf_list = {}
	for _, file in ipairs(all_files) do
		local file_bookmarks = bookmarks.get_all_by_file_id(file.id)
		for _, item in ipairs(file_bookmarks) do
			local ok, line_text = pcall(function()
				local bufnr = vim.fn.bufadd(path .. file.path)
				vim.fn.bufload(bufnr)
				return vim.api.nvim_buf_get_lines(bufnr, item.lnum - 1, item.lnum, false)[1] or ""
			end)
			line_text = ok and line_text or ""
			local ann = (item.annotation and item.annotation ~= "") and ("[" .. item.annotation .. "]  ") or ""
			local text = item.sign .. "  " .. ann .. line_text
			table.insert(qf_list, { filename = path .. file.path, lnum = item.lnum, text = text })
		end
	end
	vim.fn.setqflist(qf_list)
	vim.api.nvim_command("copen")
end

function M.change_icon()
	print("stub")
end

function M.toggle_filemark()
	local bookmark = bookmarks.get()
	if bookmark ~= nil then
		bookmarks.delete()
	end
	local file = files.get()
	if file == nil then
		files.mark_file()
	elseif file.sign == nil or file.sign == "" then
		files.mark_file()
	else
		files.unmark_file()
	end
end

function M.list_file_marks_qf()
	vim.fn.setqflist({}, "r")
	local file_list = files.get_all()

	local qf_list = {}

	for _, item in ipairs(file_list) do
		-- Open the file in a buffer and get the line text
		if item.sign ~= nil and item.sign ~= "" then
			local bufnr = vim.fn.bufadd(item.projects .. item.path)
			vim.fn.bufload(bufnr)
			local line_text = vim.api.nvim_buf_get_lines(bufnr, item.lnum - 1, item.lnum, false)[1]

			table.insert(
				qf_list,
				{ filename = item.projects .. item.path, lnum = item.lnum, text = item.sign .. " " .. line_text }
			)
		end
	end
	vim.api.nvim_command("copen")

	vim.fn.setqflist(qf_list)
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
