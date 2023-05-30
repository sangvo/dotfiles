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
    opts = {}
  },
  {
    'dbinagi/nomodoro',
    opts = {
      work_time = 25,
      break_time = 5,
      menu_available = true,
      texts = {
          on_break_complete = "TIME IS UP!",
          on_work_complete = "TIME IS UP!",
          status_icon = "羽",
          timer_format = '!%0M:%0S' -- To include hours: '!%0H:%0M:%0S'
      },
      on_work_complete = function() end,
      on_break_complete = function() end
    }
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
