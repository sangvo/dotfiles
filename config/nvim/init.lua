-- source a vimscript file
vim.cmd('source ~/workspace/dotfiles/config/nvim/old.init.vim')

-- order matters
vim.cmd [[
runtime! lua/modules/options.lua
]]

