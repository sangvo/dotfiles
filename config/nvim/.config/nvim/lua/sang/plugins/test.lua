return {
	{
		"vim-test/vim-test",
		cmd = { "TestFile", "TestNearest", "TestClass" },
		config = function()
			vim.g["test#strategy"] = "neovim"
			vim.g["test#neovim#term_position"] = "vert"

			vim.g["test#python#runner"] = "pytest"
			vim.g["test#ruby#runner"] = "rspec"

			local cmd = "pytest -v"
			if vim.fs.find("bin/run.sh", {}) then
				cmd = "./bin/run.sh " .. cmd
			end
			vim.g["test#python#pytest#executable"] = cmd
		end,
		keys = {
			{
				"<leader>tn",
				"<cmd>TestNearest<cr>",
			}, -- call test for function in cursor
			{
				"<leader>tf",
				"<cmd>TestFile<cr>",
			}, -- call test for current file
			{
				"<leader>tc",
				"<cmd>TestClass<cr>",
			}, -- call test for a specific class
		},
	},
}
