local present, nvimtree = pcall(require, "neogit")

if not present then
  return
end

require('neogit').setup {
  integrations = { diffview = true },
}
