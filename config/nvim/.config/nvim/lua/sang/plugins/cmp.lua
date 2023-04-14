return {
  -- snippets
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },

    -- stylua: ignore
    keys = {
      {
        "<tab>",
        function()
          return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
        end,
        expr = true, silent = true, mode = "i",
      },
      { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
      { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
    },
  },

  -- auto completion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
    },
    opts = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local check_backspace = function()
        local col = vim.fn.col(".") - 1
        return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
      end

      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          -- move up/down in the completion list
          ["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
          ["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),

          -- move up/down in the info list for a completion item
          ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),

          -- lists all possible options
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),

          -- this will abort the completion list
          ["<C-e>"] = cmp.mapping({
            i = cmp.mapping.abort(), -- insert mode
            c = cmp.mapping.close(), -- cmd mode
          }),

          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          }),

          ["<C-l>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          }),

          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expandable() then
              luasnip.expand()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif check_backspace() then
              fallback()
            else
              fallback()
            end
          end, {
            "i",
            "s",
          }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, {
            "i",
            "s",
          }),

        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          format = require("lspkind").cmp_format({
              mode = "symbol_text", -- show only symbol annotations
              maxwidth = 50, -- the popup will only show a max of 50 chars
              with_text = false, -- idk

              -- This is what all your completion items will be called
              menu = {
                buffer = "BUF",
                rg = "RG",
                nvim_lsp = "LSP",
                path = "PATH",
                luasnip = "SNIP",
              },
            })
        },
        experimental = {
          ghost_text = {
            hl_group = "LspCodeLens",
          },
        },
      }
    end,
  },
}
