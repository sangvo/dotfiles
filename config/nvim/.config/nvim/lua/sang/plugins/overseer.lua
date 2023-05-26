return {
  "stevearc/overseer.nvim", -- Task runner and job management
  opts = {
    templates = { "builtin", "user.run_script" },
    task_list = {
      direction = "right",
    },
  },
  keys = {
    {
      "<leader>ol",
      function()
        local overseer = require("overseer")
        local tasks = overseer.list_tasks({ recent_first = true })
        if vim.tbl_isempty(tasks) then
          vim.notify("No tasks found", vim.log.levels.WARN)
        else
          overseer.run_action(tasks[1], "restart")
        end
      end,
      desc = "Rerun last",
    },
    { "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Overseer" },
    { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Overseer run" },
  }
}
