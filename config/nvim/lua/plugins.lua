local status, packer = pcall(require, "packer")
if (not status) then
  print("Packer is not installed")
  return
end

vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use { 'wbthomason/packer.nvim', opt = true }

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
  use 'tpope/vim-repeat'
  use 'AndrewRadev/splitjoin.vim'
  use 'vim-test/vim-test'
  use 'kamykn/spelunker.vim'
  use { 'glepnir/galaxyline.nvim', branch = 'main' }
  use 'kyazdani42/nvim-tree.lua'
  use { 'akinsho/bufferline.nvim', tag = 'v2.*' }
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-compe'
  use 'norcalli/nvim-colorizer.lua'
  use 'hrsh7th/vim-vsnip'
  use 'onsails/lspkind-nvim'
  use 'airblade/vim-gitgutter'
  use { 'rafamadriz/friendly-snippets', branch = 'main' }
  use 'windwp/nvim-autopairs'
  use { 'windwp/nvim-ts-autotag', branch = 'main' }
  use 'andymass/vim-matchup'
  use 'famiu/bufdelete.nvim'
  use { "ellisonleao/gruvbox.nvim" }
  use({
    'glepnir/zephyr-nvim',
    requires = { 'nvim-treesitter/nvim-treesitter', opt = true },
  })
  use 'nvim-treesitter/nvim-treesitter'
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use 'RRethy/nvim-treesitter-endwise'
  use 'editorconfig/editorconfig-vim'
end)
