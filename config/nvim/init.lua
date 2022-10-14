require("bootstrap")
require("impatient").enable_profile()
-- enable filetype.lua
vim.g.do_filetype_lua = 1

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- prevent typo when pressing `wq` or `q`
vim.cmd [[
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
cnoreabbrev <expr> WQ ((getcmdtype() is# ':' && getcmdline() is# 'WQ')?('wq'):('WQ'))
cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
]]


-- order matters
vim.cmd [[
runtime! lua/modules/options.lua
runtime! lua/modules/mappings.lua
]]

-- source a vimscript file
vim.cmd('source ~/workspace/dotfiles/config/nvim/old.init.vim')
require("theme")
