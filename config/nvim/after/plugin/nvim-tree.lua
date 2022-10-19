local present, nvimtree = pcall(require, "nvim-tree")

if not present then
  return
end

vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1


require("nvim-tree").setup({
  open_on_setup = true,
  sort_by = "case_sensitive",
  view = {
    adaptive_size = true,
    mappings = {
      list = {
        { key = "u", action = "dir_up" },
      },
    },
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
  update_focused_file = {
    enable = true,
    update_root = false,
    ignore_list = {},
  },
})

-- Mappings for nvimtree
vim.api.nvim_set_keymap(
    "n",
    "<C-b>",
    ":NvimTreeToggle<CR>",
    {
        noremap = true,
        silent = true
    }
)

-- See more mappings: :help nvim-tree.view.mappings
