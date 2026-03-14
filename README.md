# 📚 bookmark.nvim
Bookmark and jump between lines in the current file

![getoverhere](https://user-images.githubusercontent.com/29136904/239709111-a29a2340-0272-4858-83f4-84aad250d9d1.png)

🚧This plugin is in alpha expect bugs please report issues 🚧

## Install

```
"ChristianChiarulli/bookmark.nvim"
"kkharji/sqlite.lua"
```

## Setup

```
require("bookmark").setup {
  sign = "",
  highlight = "Function",
}
```

## Commands

```
BookmarkToggle
BookmarkNext
BookmarkPrev
BookmarkList
BookmarkListProject
BookmarkAnnotate
BookmarkClear
BookmarkClearProject

FilemarkToggle
FilemarkNext
FilemarkPrev
FilemarkList
```

- `BookmarkList` — quickfix list of bookmarks in current buffer
- `BookmarkListProject` — quickfix list of all bookmarks in the project
- `BookmarkAnnotate` — add or edit an annotation on the bookmarked line (shown as virtual text)

## Telescope

You will need to load the extension first:

```
require("telescope").load_extension('bookmark')
```

Then call it with:

```
:Telescope bookmark filemarks
:Telescope bookmark bookmarks
:Telescope bookmark project_bookmarks
```

- `filemarks` — browse file marks in the project
- `bookmarks` — browse bookmarks in the current buffer
- `project_bookmarks` — browse all bookmarks across the project

## Database

The sqlite db is located at `~/.local/share/nvim/bookmark_db`

## TODO

- fix bookmark and filemark on same line

- associate marks with git hash

- option for harpoon like behavior for filemarks
- dynamic project directory (at least remove OS specific path use ~ instead of /Users/chris or /home/chris)

## TODO (Low Priority)

- allow user to specify where DB is saved
- allow bookmark jumping between files
- allow user to select from a list of predefined icons
- parameter on create for character
