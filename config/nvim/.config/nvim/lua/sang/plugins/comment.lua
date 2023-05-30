return {
	{ "JoosepAlviste/nvim-ts-context-commentstring", lazy = true },
	{
		"folke/todo-comments.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = true,
    -- stylua: ignore
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
    },
	},
	{
		"echasnovski/mini.comment",
		event = "VeryLazy",
		opts = {
			options = {
				custom_commentstring = function()
         ---@diagnostic disable-next-line: missing-parameter
					return require("ts_context_commentstring.internal").calculate_commentstring()
				end,
			},
		},
	},
}
