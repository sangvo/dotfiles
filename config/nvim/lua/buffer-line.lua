-- colors

local bar_fg = "#565c64"
local activeBuffer_fg = "#c8ccd4"

require "bufferline".setup {
    options = {
        buffer_close_icon = "",
        modified_icon = "",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        max_name_length = 14,
        max_prefix_length = 13,
        tab_size = 18,
        enforce_regular_tabs = true,
        view = "multiwindow",
        numbers = "ordinal",
        show_buffer_close_icons = true,
        separator_style = "thin"
    },
    highlights = {
    }
}

local opt = {silent = true}

local map = vim.api.nvim_set_keymap
vim.g.mapleader = " "

-- tabnext and tabprev
map("n", "<<Leader>-l>", [[<Cmd>BufferLineCycleNext<CR>]], opt)
map("n", "<<Leader>-h>", [[<Cmd>BufferLineCyclePrev<CR>]], opt)
