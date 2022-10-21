local present, lspconfig = pcall(require, "lspconfig")

if not present then
	return
end

require("mason").setup()
require("lsp_signature").setup({})

require("mason-lspconfig").setup({
	ensure_installed = {
		"html",
		"cssls",
		"tsserver",
		"solargraph",
		"bashls",
		"vuels",
		"gopls",
		"rust_analyzer",
		"tailwindcss",
	},
})

-- shorthands for null-ls
local nls = require("null-ls")
local formatting = nls.builtins.formatting
local diagnostics = nls.builtins.diagnostics
local code_actions = nls.builtins.code_actions

-- shorthand for lspconfig
local lspconfig = require("lspconfig")

nls.setup({
	autostart = true,
	sources = {
		formatting.stylua,
		formatting.prettierd,
		code_actions.eslint_d,
		diagnostics.eslint_d,
		diagnostics.golangci_lint,
		formatting.eslint_d,
		formatting.gofmt,
		diagnostics.rubocop.with({
			command = "bundle",
			args = vim.list_extend({ "exec", "rubocop" }, diagnostics.rubocop._opts.args),
		}),
		formatting.rubocop.with({
			command = "bundle",
			args = vim.list_extend({ "exec", "rubocop" }, diagnostics.rubocop._opts.args),
		}),
	},
	root_dir = lspconfig.util.root_pattern(
		"stylua.toml",
		".eslintrc.js",
		".eslintrc.cjs",
		".eslintrc.yaml",
		".eslintrc.yml",
		".eslintrc.json",
		".prettierc",
		".prettierc.json",
		".prettierc.yaml",
		".prettierc.yml",
    ".rubocop.yml"
	),
})

local lsp_defaults = lspconfig.util.default_config
local default_capabilities = require("cmp_nvim_lsp").default_capabilities()

lsp_defaults.capabilities = vim.tbl_deep_extend("force", lsp_defaults.capabilities, default_capabilities)
local servers =
	{ "html", "cssls", "tsserver", "solargraph", "bashls", "vuels", "gopls", "rust_analyzer", "tailwindcss" }

for k, lang in pairs(servers) do
	lspconfig[lang].setup({})
end

-- TODO: Custom server

-- Mapping
vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function()
		local bufmap = function(mode, lhs, rhs)
			local opts = { buffer = true }
			vim.keymap.set(mode, lhs, rhs, opts)
		end

		-- Displays hover information about the symbol under the cursor
		bufmap("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>")

		-- Jump to the definition
		bufmap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")

		-- Jump to declaration
		bufmap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>")

		-- Lists all the implementations for the symbol under the cursor
		bufmap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>")

		-- Jumps to the definition of the type symbol
		bufmap("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>")

		-- Lists all the references
		bufmap("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>")

		-- Displays a function's signature information
		bufmap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>")

		-- Renames all references to the symbol under the cursor
		bufmap("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>")

		-- Selects a code action available at the current cursor position
		bufmap("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>")
		bufmap("x", "<F4>", "<cmd>lua vim.lsp.buf.range_code_action()<cr>")

		-- Show diagnostics in a floating window
		bufmap("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>")

		-- Move to the previous diagnostic
		bufmap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>")

		-- Move to the next diagnostic
		bufmap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>")

		-- Format code
		bufmap("n", "<Leader>=", vim.lsp.buf.format, { bufnr = 0 })
	end,
})
