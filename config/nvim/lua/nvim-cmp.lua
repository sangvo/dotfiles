local present, cmp = pcall(require, "cmp")

if not present then
  return

end
local cmp = require 'cmp'
local luasnip = require 'luasnip'
local lspkind = require 'lspkind'

local check_backspace = function()
  local col = vim.fn.col '.' - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match '%s'
end

vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  window = {
    documentation = {
      border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
    },
  },
  mapping = {
    -- move up/down in the completion list
    ['<C-k>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
    ['<C-j>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),

    -- move up/down in the info list for a completion item
    ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),

    -- lists all possible options
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),

    -- this will abort the completion list
    ['<C-e>'] = cmp.mapping {
      i = cmp.mapping.abort(), -- insert mode
      c = cmp.mapping.close(), -- cmd mode
    },

    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },

    ['<C-l>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },

    ['<Tab>'] = cmp.mapping(function(fallback)
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
      'i',
      's',
    }),

    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {
      'i',
      's',
    }),
  },

  -- styling
  formatting = {
    format = lspkind.cmp_format {
      mode = 'symbol', -- show only symbol annotations
      maxwidth = 50, -- the popup will only show a max of 50 chars
      with_text = false, -- idk

      -- This is what all your completion items will be called
      menu = {
        buffer = 'BUF',
        rg = 'RG',
        nvim_lsp = 'LSP',
        path = 'PATH',
        luasnip = 'SNIP',
        calc = 'CALC',
        spell = 'SPELL',
        emoji = 'EMOJI',
      },
    },
  },

  -- This controls the order of the snippets
  sources = {
    { name = 'nvim_lua' },
    { name = 'nvim_lsp' }, -- these are shown first
    { name = 'buffer', keyword_length = 5 },
    { name = 'luasnip' },
    { name = 'calc' },
    { name = 'emoji' },
    { name = 'spell' },
    { name = 'path' },
    { name = 'rg', keyword_length = 5 },
  },
}

-- Use buffer source for `/`.
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' },
  },
})

-- Use cmdline & path source for ':'.
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({ { name = 'path' } }, {
    { name = 'cmdline' },
  }),
})
