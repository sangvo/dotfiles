vim.filetype.add({
	extension = {
		ejs = "html",
		hbs = "handlebars",
		svx = "markdown",
		mdx = "markdown",
		md = "markdown",
		rasi = "css",
		norg = "norg", -- TreeSitter
		patch = "patch",
		tsx = "typescriptreact",
		jsx = "typescriptreact",
    slim = "ruby",
	},
	filename = {
		[".prettierrc"] = "jsonc",
		[".eslintrc"] = "jsonc",
		["tsconfig.json"] = "jsonc",
		["jsconfig.json"] = "jsonc",
	},
})
