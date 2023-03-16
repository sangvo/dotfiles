local present, nvimtree = pcall(require, "nvim-tree")

if not present then
  return
end

vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1


local function open_nvim_tree(data)

  -- buffer is a [No Name]
  local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

  -- buffer is a directory
  local directory = vim.fn.isdirectory(data.file) == 1

  if not no_name and not directory then
    return
  end

  -- change to the directory
  if directory then
    vim.cmd.cd(data.file)
  end

  -- open the tree
  require("nvim-tree.api").tree.open()
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

require("nvim-tree").setup({
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
