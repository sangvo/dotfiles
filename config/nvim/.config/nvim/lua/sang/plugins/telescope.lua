return {
  {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
    "nvim-telescope/telescope-ui-select.nvim",
    }
  },
  keys = {
    {
      "<C-p>",
      require("telescope.builtin").find_files,
      desc = "Fuzzy find files using Telescope",
    },
    {
      "<C-f>",
      	require("telescope.builtin").grep_string({
          path_display = { "smart" },
          search = vim.fn.input("Grep String > "),
          only_sort_text = true,
          use_regex = true,
        }),
      desc = "Fuzzy grep files using Telescope",
    }
  },
  opts = {
    defaults = {
      scroll_strategy = "cycle",
      selection_strategy = "reset",
      layout_strategy = "flex",
      borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      layout_config = {
        horizontal = {
          width = 0.8,
          height = 0.8,
          preview_width = 0.4,
        },
        vertical = {
          height = 0.8,
          preview_height = 0.5,
        },
      },
      mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,

          ["<C-v>"] = actions.select_vertical,
          ["<C-x>"] = actions.select_horizontal,
          ["<C-t>"] = actions.select_tab,

          ["<C-c>"] = actions.close,
          -- ["<Esc>"] = actions.close,

          ["<C-u>"] = actions.preview_scrolling_up,
          ["<C-d>"] = actions.preview_scrolling_down,
          ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
          ["<Tab>"] = actions.toggle_selection,
          -- ["<C-r>"] = actions.refine_result,
        },
        n = {
          ["<CR>"] = actions.select_default + actions.center,
          ["<C-v>"] = actions.select_vertical,
          ["<C-x>"] = actions.select_horizontal,
          ["<C-t>"] = actions.select_tab,
          ["<Esc>"] = actions.close,

          ["j"] = actions.move_selection_next,
          ["k"] = actions.move_selection_previous,

          ["<C-u>"] = actions.preview_scrolling_up,
          ["<C-d>"] = actions.preview_scrolling_down,
          ["<C-q>"] = actions.send_to_qflist,
          ["<Tab>"] = actions.toggle_selection,
        },
      }
		},
    pickers = {
      grep_string = dropdown({
        file_ignore_patterns = ignored_list,
      }),
      find_files = {
        file_ignore_patterns = ignored_list,
      },
      lsp_references = dropdown(),
      lsp_document_symbols = dropdown(),
      current_buffer_fuzzy_find = no_preview(),
    },
    extensions = {
		["ui-select"] = no_preview(),
		fzf = {
			override_generic_sorter = true,
			override_file_sorter = true,
		},
    }
  },
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup(opts)
    telescope.load_extension("fzf")
    telescope.load_extension("ui-select")
  end,
}
