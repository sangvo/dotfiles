-- [[ toggleterm.nvim ]]
-- A togglable terminal at the bottom of the screen for running code / commands.
--  Press <C-\> anywhere to open it, <C-\> again to hide it (the session persists).
--  Exit terminal-insert mode back to Normal with <Esc><Esc> (mapped in init.lua).
--  See https://github.com/akinsho/toggleterm.nvim
vim.pack.add { { src = 'https://github.com/akinsho/toggleterm.nvim', version = vim.version.range '*' } }

require('toggleterm').setup {
  open_mapping = [[<C-\>]], -- toggle from normal / insert / terminal mode
  direction = 'horizontal', -- split at the bottom
  size = 15, -- rows tall
  start_in_insert = true,
  persist_size = true,
  persist_mode = true,
  shade_terminals = true, -- slightly darken the terminal so it stands out
}

-- Make window navigation and escaping work naturally from inside the terminal.
vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('custom-toggleterm-keys', { clear = true }),
  pattern = 'term://*toggleterm#*',
  callback = function()
    local opts = { buffer = 0 }
    -- Move to another window straight from terminal mode.
    vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
  end,
})
