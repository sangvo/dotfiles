return {
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        close_command = function(bufnum)
          require("bufdelete").bufdelete(bufnum, true)
        end,
        buffer_close_icon = "",
        separator_style = { "", "" },
        indicator = {
          icon = "┃",
          style = "icon",
        },
        color_icons = true,
        diagnostics_indicator = function(_, _, diag)
          local icons = {
            Error = " ",
            Warn = " ",
            Hint = " ",
            Info = " ",
          }
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            text = "EXPLORER",
            filetype = "NvimTree",
            text_align = "center",
            separator = true,
          },
          {
            text = " DIFF VIEW",
            filetype = "DiffviewFiles",
            separator = true,
          },
        },
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      -- char = "▏",
      char = "¦",
      filetype_exclude = { "help", "alpha", "dashboard", "Trouble", "lazy" },
      show_trailing_blankline_indent = false,
      show_current_context = false,
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      icons_enabled = true,
      theme = 'auto',
      disabled_filetypes = { 'NvimTree' },
    }
  }
}
