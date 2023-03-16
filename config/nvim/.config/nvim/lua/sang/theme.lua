vim.g.colors_name = "nightfly"
vim.o.background = "dark"

-- Set background terminal and line number transparent
vim.cmd([[
hi clear SignColumn
hi Normal ctermbg=NONE guibg=NONE
hi VertSplit guifg=#3D4C4C guibg=reverse gui=NONE cterm=NONE

hi SpelunkerSpellBad cterm=underline ctermfg=247 gui=underline guifg=NONE
hi SpelunkerComplexOrCompoundWord cterm=underline ctermfg=NONE gui=underline guifg=NONE

hi CursorLine	guibg=#3D4C4C
hi ColorColumn ctermbg=235 guibg=#3D4C4C
]])

-- Change color folder nvim-tree
vim.cmd([[hi NvimTreeFolderName guifg = '#6699cc']])
