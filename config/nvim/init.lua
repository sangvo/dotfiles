-- enable filetype.lua
vim.g.do_filetype_lua = 1

-- source a vimscript file
vim.cmd('source ~/workspace/dotfiles/config/nvim/old.init.vim')

-- order matters
vim.cmd [[
runtime! lua/modules/options.lua
]]

