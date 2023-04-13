return {
    -- Dependencies
  "nvim-lua/plenary.nvim",
  "nvim-tree/nvim-web-devicons",

  -- Navigation
  "christoomey/vim-tmux-navigator",

  -- Wakatime
  -- "wakatime/vim-wakatime",

  -- Plugins
  "kylechui/nvim-surround",
  "numToStr/Comment.nvim",
  "AndrewRadev/splitjoin.vim",
  "vim-test/vim-test",
  "kamykn/spelunker.vim",
  "onsails/lspkind-nvim",
  { "rafamadriz/friendly-snippets", branch = "main" },
  "andymass/vim-matchup",
  "famiu/bufdelete.nvim",
  "editorconfig/editorconfig-vim",
  { "dstein64/vim-startuptime" },
  "danymat/neogen",
  "fatih/vim-go",

  -- Mappings
  "folke/which-key.nvim",

  -- Easy motion
  "phaazon/hop.nvim",

  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lua" },
  },
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "jayp0521/mason-null-ls.nvim",
  "ray-x/lsp_signature.nvim",
  "jose-elias-alvarez/null-ls.nvim",
  { "L3MON4D3/LuaSnip", version = "v<CurrentMajor>.*" },

  -- Telescope
  -- "nvim-telescope/telescope.nvim",
  -- { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  -- "nvim-telescope/telescope-ui-select.nvim",

  -- Git
  "TimUntersberger/neogit",
  "sindrets/diffview.nvim",

  -- CMP
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "lukas-reineke/cmp-rg",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
    },
    event = { "BufNewFile", "BufRead", "InsertEnter" },
  },
}
