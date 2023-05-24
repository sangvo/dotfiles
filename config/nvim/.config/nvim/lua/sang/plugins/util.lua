return {

  -- measure startuptime
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 10
    end,
  },
  {
    "windwp/nvim-autopairs",
    config = function ()
      require("nvim-autopairs").setup()
    end
  },
  {
    "danymat/neogen",
    config = function ()
      require('neogen').setup()
    end
  },
  {
    "kylechui/nvim-surround",
    config = function ()
      require('nvim-surround').setup()
    end
  },
  -- library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = true },
  { "onsails/lspkind-nvim",lazy =true},

  -- makes some plugins dot-repeatable like leap
  { "tpope/vim-repeat", event = "VeryLazy" },
  {"christoomey/vim-tmux-navigator", event = "VeryLazy"},
  {"famiu/bufdelete.nvim", event = "VeryLazy"},
}
