vim.g.ale_disable_lsp = 1
vim.g.ale_fix_on_save = 0
vim.g.ale_hover_cursor = 0

vim.g.ale_sign_error = "✘"
vim.g.ale_sign_warning = " ●"

vim.g.ale_javascript_eslint_suppress_missing_config = 1
-- vim.g.ale_textlint_options = "-c ~/.config/textlint/textlintrc.yml"

-- Disable all linters
--   When set to 1, only the linters from g:ale_linters and b:ale_linters
--   will be enabled. The default behavior for ALE is to enable as many linters
--   as possible, unless otherwise specified.
vim.g.ale_linters_explicit = 1

vim.g.ale_linters = {
  ruby = { 'rubocop' },
  rspec = { 'rubocop' },
  vue = { 'eslint', 'vls' },
  json = { 'jq', 'jsonlint' },
  go = { 'gopls' },
}

vim.g.ale_fixers = {
  javascript = { 'eslint' },
  vue = { 'eslint' },
  ruby = { 'rubocop' },
}

if vim.fn.executable(vim.fn.getcwd() .. "/vendor/bin/rubocop") == 1 then
	vim.g.ale_ruby_rubocop_executable = "bundle"
end

vim.api.nvim_create_user_command("ToggleALEAutoFix", function()
	if vim.g.ale_fix_on_save == 1 then
		vim.g.ale_fix_on_save = 0
	else
		vim.g.ale_fix_on_save = 1
	end
end, { nargs = 0 })
