return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    build = function()
      require("nvim-treesitter.install").update({ with_sync = true })
    end,
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        init = function()
          -- PERF: no need to load the plugin, if we only need its queries for mini.ai
          local plugin = require("lazy.core.config").spec.plugins["nvim-treesitter"]
          local opts = require("lazy.core.plugin").values(plugin, "opts", false)
          local enabled = false
          if opts.textobjects then
            for _, mod in ipairs({ "move", "select", "swap", "lsp_interop" }) do
              if opts.textobjects[mod] and opts.textobjects[mod].enable then
                enabled = true
                break
              end
            end
          end
          if not enabled then
            require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
          end
        end,
      },
      "RRethy/nvim-treesitter-endwise",
      "windwp/nvim-ts-autotag",
    },
    opts = {
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
      autopairs = { enable = true },
      autotag = { enable = true },
      highlight = { enable = true },
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
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
