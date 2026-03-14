local M = {}

local sqlite = require("sqlite")
local uri = vim.fn.stdpath('data') .. "/bookmark_db"

M.projects = require("bookmark.datastore.project_tbl")
M.files = require("bookmark.datastore.file_tbl")
M.bookmarks = require("bookmark.datastore.bookmark_tbl")

-- Migration: add annotation column if missing. sqlite3 CLI is used for reliability.
-- Silently fails if db/table doesn't exist yet (first run) or column already exists.
vim.fn.system({ "sqlite3", uri, "ALTER TABLE bookmarks ADD COLUMN annotation TEXT" })

sqlite({
	uri = uri,
	projects = M.projects.projects,
	files = M.files.files,
	bookmarks = M.bookmarks.bookmarks,
	opts = {},
})

return M
