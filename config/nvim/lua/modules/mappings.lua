local u = require "modules.util"
local noremap = u.noremap
local nnoremap = u.nnoremap
local inoremap = u.inoremap
local tnoremap = u.tnoremap
local vnoremap = u.vnoremap

function map(mode, shortcut, command)
  vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true })
end

function nmap(shortcut, command)
  map('n', shortcut, command)
end

function imap(shortcut, command)
  map('i', shortcut, command)
end

function cmap(shortcut, command)
  map('c', shortcut, command)
end

function vmap(shortcut, command)
  map('v', shortcut, command)
end

imap("jk", "<Esc>")
map("", "0", "^")
map("", "q", "<Nop>")

-- Don't move with arrow key

nnoremap("<Left>", ':echoe "Use h"<CR>', { desc = "Use h" })
nnoremap("<Right>", ':echoe "Use l"<CR>', { desc = "Use l" })
nnoremap("<Up>", ':echoe "Use k"<CR>', { desc = "Use k" })
nnoremap("<Down>", ':echoe "Use j"<CR>', { desc = "Use j" })

-- Shift+H goto head of the line, Shift+L goto end of the line
nnoremap("H", "^")
nnoremap("L", "$")

-- Useful saving mapping
nnoremap("<leader>w", ":w!<cr>", { desc = "Force save" })
nnoremap("<C-S>", ":update<CR>", { desc = "Force save" })
vnoremap("<C-S>", "<C-C>:update<CR>", { desc = "Force save" })
inoremap("<C-S>", "<C-C>:update<CR>", { desc = "Force save" })

vim.api.nvim_create_user_command(
  'W',
  'execute w !sudo tee % > /dev/null) <bar> edit!',
  { bang = true }
)

-- Switch CWD to the directory of the open buffer
map("", "<leader>cd", ":cd %:p:h<cr>:pwd<cr>")

-- Copy to clipboard
vmap("<C-C>", '"+y')
vmap("<leader>y", '"+y')
nmap("<leader>y", '"+y')
nmap("<leader>p", '"+p')

-- Yank to end
nnoremap("Y", "y$", { desc = "Yank to end" })

-- Move a line of text using ALT+[jk]
nmap("<M-j>", "mz:m+<cr>`z")
nmap("<M-k>", "mz:m-2<cr>`z")
vmap("<M-j>", ":m'>+<cr>`<my`>mzgv`yo`z")
vmap("<M-k>", ":m'<-2<cr>`>my`<mzgv`yo`z")

-- Turn off search highlight
map("", "<leader><cr>", ":noh<cr>")

-- Split windows
map("", "<leader>sv", "<C-W>v")
map("", "<<leader>ss>sv", "<C-W>s")

-- Resize panel
nmap("<C-w>[", ":vertical resize -6<CR>")
nmap("<C-w>]", ":vertical resize +6<CR>")

-- Goto buffer
nnoremap("<Leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>")
nnoremap("<Leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>")
nnoremap("<Leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>")
nnoremap("<Leader>4", "<Cmd>BufferLineGoToBuffer 4<CR>")
nnoremap("<Leader>5", "<Cmd>BufferLineGoToBuffer 5<CR>")
nnoremap("<Leader>6", "<Cmd>BufferLineGoToBuffer 6<CR>")
nnoremap("<Leader>7", "<Cmd>BufferLineGoToBuffer 7<CR>")
nnoremap("<Leader>8", "<Cmd>BufferLineGoToBuffer 8<CR>")
nnoremap("<Leader>9", "<Cmd>BufferLineGoToBuffer 9<CR>")
nnoremap("<Leader>$", "<Cmd>BufferLineGoToBuffer -1<CR>")

