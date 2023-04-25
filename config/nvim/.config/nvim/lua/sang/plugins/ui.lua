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
            separator = "┃",
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
    opts = function ()
      return {
        options = {
          icons_enabled = true,
          theme = 'auto',
          disabled_filetypes = { },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename' },
          lualine_x = {
            {
              function() return "  " .. require("dap").status() end,
              cond = function () return package.loaded["dap"] and require("dap").status() ~= "" end,
              color = { fg = "#fc514e" },
              separator = ""
            },
            {
              -- Lsp server name .
              function()
                local msg = 'No LSP'
                local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
                local clients = vim.lsp.get_active_clients()
                if next(clients) == nil then
                  return msg
                end
                for _, client in ipairs(clients) do
                  local filetypes = client.config.filetypes
                  if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                    return client.name
                  end
                end
                return msg
              end,
              icon = ' ',
              color = { fg = '#82aaff', gui = 'bold' },
              separator = ""
            },
            {
              function()
                return " " .. "%3{codeium#GetStatusString()}"
              end,
              color = { fg = '#e3d18a' },
              separator = ""
            },
            'encoding',
            'filetype'
          },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        }
      }
    end
  }
}
