vim.cmd[[
colorscheme zephyr
]]
vim.o.background = "dark"

-- Set background terminal and line number transparent
vim.cmd[[
hi clear SignColumn
hi Normal ctermbg=NONE guibg=NONE
hi VertSplit guifg=#343D46 guibg=#343D46 gui=NONE cterm=NONE

hi SpelunkerSpellBad cterm=underline ctermfg=247 gui=underline guifg=NONE
hi SpelunkerComplexOrCompoundWord cterm=underline ctermfg=NONE gui=underline guifg=NONE
]]

-- Change color folder nvim-tree
vim.cmd[[hi NvimTreeFolderName guifg = '#6699cc']]

-- Syntastics
vim.api.nvim_set_hl(0, 'ALEErrorSign', { fg="#FF5555" })
vim.api.nvim_set_hl(0, 'ALEVirtualTextError', { fg="#AAAAAA", bg="#FFEFEF" })

vim.api.nvim_set_hl(0, 'ALEWarningSign', { fg="#FFA500" })
vim.api.nvim_set_hl(0, 'ALEVirtualTextWarning', { fg="#AAAAAA", bg="#FFF3D0" })
vim.api.nvim_set_hl(0, 'ALEStyleErrorSign', { fg="#FF5555" })
vim.api.nvim_set_hl(0, 'ALEVirtualTextStyleError', { fg="#AAAAAA", bg="#FFEFEF" })
vim.api.nvim_set_hl(0, 'ALEStyleWarningSign', { fg="#AAAAFF" })
vim.api.nvim_set_hl(0, 'ALEVirtualTextStyleWarning', { fg="#AAAAAA", bg="#FFF3D0" })


