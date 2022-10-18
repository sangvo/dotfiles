local status, packer = pcall(require, "packer")
if (not status) then
  print("Packer is not installed")
  return
end

return require('packer').startup(function(use)
  -- Dependencies
  use 'nvim-lua/plenary.nvim'
  use 'kyazdani42/nvim-web-devicons'
  use { 'junegunn/fzf', run = ":call fzf#install()" }

  -- Navigation
  use 'christoomey/vim-tmux-navigator'

  -- Plugins
  use { 'junegunn/fzf.vim' }
  use 'tpope/vim-surround'
  use 'Yggdroot/indentLine'
  use 'tpope/vim-commentary'
  use 'dense-analysis/ale'
  use 'AndrewRadev/splitjoin.vim'
  use 'vim-test/vim-test'
  use 'kamykn/spelunker.vim'
  use { 'glepnir/galaxyline.nvim', branch = 'main' }
  use 'kyazdani42/nvim-tree.lua'
  use { 'akinsho/bufferline.nvim', tag = 'v2.*' }
  use 'norcalli/nvim-colorizer.lua'
  use 'onsails/lspkind-nvim'
  use 'airblade/vim-gitgutter'
  use { 'rafamadriz/friendly-snippets', branch = 'main' }
  use 'windwp/nvim-autopairs'
  use { 'windwp/nvim-ts-autotag', branch = 'main' }
  use 'andymass/vim-matchup'
  use 'famiu/bufdelete.nvim'
  -- use({
  --   'glepnir/zephyr-nvim',
  --   requires = { 'nvim-treesitter/nvim-treesitter', opt = true },
  -- })
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use 'RRethy/nvim-treesitter-endwise'
  use 'editorconfig/editorconfig-vim'
  use { 'heavenshell/vim-jsdoc', run = 'make install' }
  use { 'dstein64/vim-startuptime' }
  use 'bluz71/vim-nightfly-guicolors'

  -- LSP
  use 'neovim/nvim-lspconfig'
  use "williamboman/mason.nvim"
  use 'ray-x/lsp_signature.nvim'
  use 'jose-elias-alvarez/null-ls.nvim'
  use({"L3MON4D3/LuaSnip", tag = "v<CurrentMajor>.*"})

  -- CMP
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/cmp-calc'
  use 'lukas-reineke/cmp-rg'
  use 'saadparwaiz1/cmp_luasnip'
  use 'hrsh7th/cmp-nvim-lua'
end)
