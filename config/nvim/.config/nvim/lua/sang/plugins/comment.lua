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
		"numToStr/Comment.nvim",
		event = "VeryLazy",
		opts = {
			pre_hook = function()
				require("ts_context_commentstring.internal").update_commentstring({})
			end,
		},
		config = function(_, opts)
			require("Comment").setup(opts)
		end,
	},
}
