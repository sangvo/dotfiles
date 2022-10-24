require("which-key").register({
  g = {
    name = "Git",
    b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
    B = {
      "<cmd>Telescope git_bcommits<cr>",
      "Checkout commits (for the current file)",
    },
    C = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
    d = { "<cmd>DiffviewOpen<cr>", "Open DiffView" },
    D = { "<cmd>DiffviewClose<cr>", "Close DiffView" },
    j = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", "Next Hunk" },
    k = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", "Prev Hunk" },
    n = { "<cmd>Neogit<cr>", "Open Neogit" },
    p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
    R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
    r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
    S = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
    s = { "<cmd>Telescope git_status<cr>", "Open changed file" },
    u = {
      "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
      "Undo Stage Hunk",
    },
  },
}, { prefix = "<Leader>", mode = "n" })
