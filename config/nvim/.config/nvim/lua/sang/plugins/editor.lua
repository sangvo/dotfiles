return {
  {
    "Wansmer/treesj",
    keys = {
      { "<leader>sj", "<cmd>TSJToggle<cr>", desc = "Join Toggle" },
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      use_default_keymaps = false,
      max_join_length = 150,
      dot_repeat = true,
    },
  },
  {
    "cshuaimin/ssr.nvim",
    keys = {
      {
        "<leader>sr",
        function()
          require("ssr").open()
        end,
        mode = { "n", "x" },
        desc = "Structural Replace",
      },
    },
  }
}
