local vim = vim
local execute = vim.api.nvim_command
local fn = vim.fn
-- ensure that packer is installed
local install_path = fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
	execute("packadd packer.nvim")
end
vim.cmd("packadd packer.nvim")
local packer = require("packer")
local util = require("packer.util")
packer.init({
	package_root = util.join_paths(vim.fn.stdpath("data"), "site", "pack"),
})

-- Load packer.nvim
vim.cmd("packadd packer.nvim")

return require("packer").startup(function(use)
	-- Dependencies
	use("nvim-lua/plenary.nvim")
	use("kyazdani42/nvim-web-devicons")
	use({ "junegunn/fzf", run = ":call fzf#install()" })

	-- Navigation
	use("christoomey/vim-tmux-navigator")

	-- Plugins
	use({ "junegunn/fzf.vim" })
	use("tpope/vim-surround")
	use("Yggdroot/indentLine")
	use("tpope/vim-commentary")
	-- use 'dense-analysis/ale'
	use("AndrewRadev/splitjoin.vim")
	use("vim-test/vim-test")
	use("kamykn/spelunker.vim")
	use({ "glepnir/galaxyline.nvim", branch = "main" })
	use("kyazdani42/nvim-tree.lua")
	use({ "akinsho/bufferline.nvim", tag = "v2.*" })
	use("norcalli/nvim-colorizer.lua")
	use("onsails/lspkind-nvim")
	use("airblade/vim-gitgutter")
	use({ "rafamadriz/friendly-snippets", branch = "main" })
	use("windwp/nvim-autopairs")
	use({ "windwp/nvim-ts-autotag", branch = "main" })
	use("andymass/vim-matchup")
	use("famiu/bufdelete.nvim")
	-- use({
	--   'glepnir/zephyr-nvim',
	--   requires = { 'nvim-treesitter/nvim-treesitter', opt = true },
	-- })
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	use("nvim-treesitter/nvim-treesitter-textobjects")
	use("RRethy/nvim-treesitter-endwise")
	use("editorconfig/editorconfig-vim")
	use({ "heavenshell/vim-jsdoc", run = "make install" })
	use({ "dstein64/vim-startuptime" })
	use("bluz71/vim-nightfly-guicolors")

	-- LSP
	use({
		"neovim/nvim-lspconfig",
		requires = { "hrsh7th/cmp-nvim-lua" },
	})
	use("williamboman/mason.nvim")
	use("ray-x/lsp_signature.nvim")
	use("jose-elias-alvarez/null-ls.nvim")
	use({ "L3MON4D3/LuaSnip", tag = "v<CurrentMajor>.*" })

	-- CMP
	use({
		"hrsh7th/nvim-cmp",
		requires = {
			{ "hrsh7th/cmp-buffer", after = "nvim-cmp" },
			{ "hrsh7th/cmp-path", after = "nvim-cmp" },
			{ "hrsh7th/cmp-cmdline", after = "nvim-cmp" },
			{ "hrsh7th/cmp-calc", after = "nvim-cmp" },
			{ "lukas-reineke/cmp-rg", after = "nvim-cmp" },
			{ "saadparwaiz1/cmp_luasnip", after = "nvim-cmp" },
			{ "hrsh7th/cmp_luasnip", after = "nvim-cmp" },
		},
		after = { "LuaSnip", "nvim-treesitter" },
		wants = { "LuaSnip" },
		event = { "BufNewFile", "BufRead", "InsertEnter" },
	})
	use("hrsh7th/cmp-nvim-lsp")
end)
