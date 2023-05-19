local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

-- local actions = require("telescope.actions")
-- local action_state = require("telescope.actions.state")

local files = require("bookmark.datastore.file_tbl")

local get_file_list = function()
	local marked_files = files.get_all_marked()
	local file_list = {}
	for _, file in ipairs(marked_files) do
		table.insert(file_list, { file.path, file.lnum, file.sign_id, file.projects })
	end
	return file_list
end

-- { {
--     id = 4,
--     lnum = 8,
--     path = "/lua/bookmark/telescope/_extensions/bookmark-telescope.lua",
--     projects = "/Users/chris/.local/share/lunarvim/site/pack/lazy/opt/bookmark.nvim",
--     sign = "󱡅",
--     sign_id = 1
--   } }

return function(opts)
	opts = opts or {}
	pickers
		.new(opts, {
			sorter = conf.generic_sorter(opts),
			previewer = conf.grep_previewer(opts),
			prompt_title = "colors",
			finder = finders.new_table({
				results = get_file_list(),
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry[1],
						ordinal = tostring(entry[1]),
						path = entry[4] .. entry[1],
						lnum = entry[2],
					}
				end,
			}),
		})
		:find()
end

-- colors(require("telescope.themes").get_dropdown({}))
