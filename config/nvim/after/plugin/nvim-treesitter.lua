local ts_config = require "nvim-treesitter.configs"

ts_config.setup {
  ensure_installed = {
    "comment",
    "css",
    "go",
    "html",
    "javascript",
    "jsdoc",
    "json",
    "jsonc",
    "markdown",
    "lua",
    "python",
    "query",
    "rust",
    "yaml",
    "tsx",
    "typescript",
    "vue",
    "ruby",
    "scss",
  },

  autotag = { enable = true },
  highlight = { enable = true },
  indent = { enable = true },
  matchup = { enable = true },
  playground = { enable = true },
  endwise = { enable = true, },

  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },

  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<Enter>",
      node_incremental = "<Enter>",
      node_decremental = "<BS>",
    },
  },

  textobjects = {
    select = {
      enable = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ab"] = "@block.outer",
        ["ib"] = "@block.inner",
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ["<Leader>a"] = "@parameter.inner",
      },
      swap_previous = {
        ["<Leader>A"] = "@parameter.inner",
      },
    },
    lsp_interop = {
      enable = true,
    },
  },
}
