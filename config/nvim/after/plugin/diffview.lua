local present, nvimtree = pcall(require, "diffview")

if not present then
  return
end

require('diffview').setup()
