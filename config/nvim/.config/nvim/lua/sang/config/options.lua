local o = vim.opt
local indent = 2

-- enable filetype.lua
vim.g.do_filetype_lua = 1

o.encoding = "UTF-8" -- set encoding
o.history = 500
o.mouse = "nvi" -- enable mouse support in normal, insert, and visual mode
o.swapfile = false -- Disable vim create swap file
o.whichwrap = "b,s,<,>,[,]"
o.autoread = true -- Set to auto read when a file is changed
o.autowrite = true -- auto write buffer when it's not focused
o.clipboard = "unnamed" -- Use the OS clipboard by default
o.hidden = true
o.mouse = "a" -- enable mouse for all mode
o.syntax = "on"
o.textwidth = 120
o.expandtab = true
o.timeoutlen = 400 -- faster timeout wait time
o.updatetime = 1000 -- set faster update time
o.sidescrolloff = 15 -- make scrolling better
o.scrolloff = 2 -- make scrolling better
o.sidescroll = 2 -- make scrolling better
o.pumheight = 10 -- limit completion items
o.wrap = false -- don't wrap lines
o.equalalways = true -- make window size always equal
o.undofile = true -- persistent undo
o.writebackup = false -- disable backup
o.backup = false -- disable backup
o.termguicolors = true
o.showmode = false -- we don't need to see things like -- INSERT -- anymore
o.conceallevel = 0 -- so that `` is visible in markdown files
o.cmdheight = 2 -- more space in the neovim command line for displaying messages

-- Indent
o.autoindent = true
o.tabstop = indent -- tabsize
o.shiftwidth = indent
o.softtabstop = indent
o.smartindent = true
o.smarttab = true -- make tab behaviour smarter

-- fold
o.foldmethod = "indent" -- Fold based on indent
o.foldnestmax = 3 -- Deepest fold is 5 levels
o.foldenable = false -- No fold when start

-- split
o.splitbelow = true -- split below instead of above
o.splitright = true -- split right instead of left

-- Set line number
o.number = true -- enable line number
o.relativenumber = true -- enable relative line number

-- Cusor
o.cursorline = true

-- Search
o.hlsearch = true -- Highlight all search results
o.smartcase = true -- Enable smart-case search
o.ignorecase = true -- Always case-insensitive
o.incsearch = true -- Searches for strings incrementally
o.so = 7 -- Set 7 lines to the cursor
o.laststatus = 3
o.ruler = true
o.wildmenu = true
o.spell = false -- turn off vim spell same work

-- better experience

o.list = true
o.fillchars = {
	vert = "│",
  horiz = "━",
  horizup = "┻",
  horizdown = "┳",
  vertleft = "┫",
  vertright = "┣",
  verthoriz = "╋",
	eob = " ",
	fold = " ",
	diff = "╱",
} -- make vertical split sign better

o.listchars = {
	-- eol = "↲",
	tab = "» ",
	space = ".",
	trail = "·",
	extends = "→",
	precedes = "←",
} -- set listchars
