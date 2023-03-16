local present, nvimtree = pcall(require, "hop")

if not present then
  return
end

require("hop").setup({
  keys = "asdghklqwertyuiopzxcvbnmfj",
})

vim.keymap.set("n", "<Leader>w", "<CMD>HopWord<CR>", {
  noremap = true,
  silent = true,
})
