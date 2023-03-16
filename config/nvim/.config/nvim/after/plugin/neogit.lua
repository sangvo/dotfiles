local present, nvimtree = pcall(require, "neogit")

if not present then
  return
end

require('neogit').setup {
  kind = "split",
  integrations = { diffview = true },
  mappings = {
    -- modify status buffer mappings
    status = {
      -- Adds a mapping with "B" as key that does the "BranchPopup" command
      ["gS"] = "StageAll"
    }
  }
}
