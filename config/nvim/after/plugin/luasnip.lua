local ls = require("luasnip")
local vsc = require("luasnip.loaders.from_vscode")
-- local lua = require("luasnip.loaders.from_lua")

-- vim.o.runtimepath = vim.o.runtimepath .. ',' .. os.getenv('HOME') .. '/.config/nvim/snippets,'

ls.config.set_config({
	history = true,
	updateevents = "TextChanged,TextChangedI",
})

-- load lua snippets
vsc.lazy_load({ paths = "~/.config/nvim/snippets" })

-- expansion key
-- this will expand the current item or jump to the next item within the snippet.
vim.keymap.set({ "i", "s" }, "<c-j>", function()
	if ls.expand_or_jumpable() then
		ls.expand_or_jump()
	end
end, { silent = true })

-- jump backwards key.
-- this always moves to the previous item within the snippet
vim.keymap.set({ "i", "s" }, "<c-k>", function()
	if ls.jumpable(-1) then
		ls.jump(-1)
	end
end, { silent = true })

-- selecting within a list of options.
vim.keymap.set("i", "<c-h>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end)
