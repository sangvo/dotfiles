return {
  {
    "kyazdani42/nvim-tree.lua",
   keys = {
      { "<C-b>", "<cmd>:NvimTreeToggle<CR>", desc = "Nvimtree" },
    },
    config =function ()
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
          exclude = {
            ".config"
          }
        },
        update_focused_file = {
          enable = true,
          update_root = false,
          ignore_list = {},
        },
      })
    end
  }
}
