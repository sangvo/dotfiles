-- enable filetype.lua
vim.g.do_filetype_lua = 1

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- order matters
vim.cmd [[
runtime! lua/modules/options.lua
runtime! lua/modules/mappings.lua
]]

-- source a vimscript file
vim.cmd('source ~/workspace/dotfiles/config/nvim/old.init.vim')
