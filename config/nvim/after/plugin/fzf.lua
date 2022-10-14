vim.env.FZF_DEFAULT_COMMAND = 'rg --files --hidden'
vim.api.nvim_command('command! -bang -nargs=* Rg call fzf#vim#grep(\'rg --column --line-number --no-heading --fixed-strings --smart-case --hidden --follow --color=always --glob "!.git/*" \'.shellescape(<q-args>), 1, <bang>0)')
vim.g['fzf_action'] = {
  ['ctrl-t'] = 'tab split',
  ['ctrl-s'] = 'split',
  ['ctrl-v'] = 'vsplit'
}
vim.g['fzf_preview_window'] = {'down:40%:+{2}-/2'}

-- vim.api.nvim_set_keymap('n', '<Leader>o', '<cmd>Files<CR>', {noremap = true}) -- Open file menu
vim.api.nvim_set_keymap('n', '\\', ':Rg<SPACE>', {noremap = true}) -- Prepare rg query
