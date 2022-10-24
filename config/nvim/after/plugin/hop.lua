local present, nvimtree = pcall(require, "hop")

if not present then
  return
end

require("hop").setup()

vim.keymap.set("n", "<Leader>w", "<CMD>HopWord<CR>", {
  noremap = true,
  silent = true,
})
