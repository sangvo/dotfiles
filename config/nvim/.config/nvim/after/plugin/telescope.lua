local present, telescope = pcall(require, "telescope")

if not present then
	return
end

local M = {}

local ignored_list = {
	"%.png",
	"%.jpg",
	"%.webp",
	"node_modules",
	"vendor",
	"*%.min%.*",
	"dotbot",
}

local _, telescope = pcall(require, "telescope")
local actions = require("telescope.actions")

local borderchars = {
	{ "─", "│", "─", "│", "┌", "┐", "┘", "└" },
	prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
	results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
	preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
}

local function no_preview(opts)
	return vim.tbl_extend(
		"force",
		require("telescope.themes").get_dropdown({
			borderchars = borderchars,
			layout_config = {
				width = 0.6,
			},
			previewer = false,
		}),
		opts or {}
	)
end

local function dropdown(opts)
	return vim.tbl_extend(
		"force",
		require("telescope.themes").get_dropdown({
			borderchars = borderchars,
			layout_config = {
				width = 0.6,
			},
		}),
		opts or {}
	)
end

telescope.setup({
	defaults = {
		scroll_strategy = "cycle",
		selection_strategy = "reset",
		layout_strategy = "flex",
		borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
		layout_config = {
			horizontal = {
				width = 0.8,
				height = 0.8,
				preview_width = 0.4,
			},
			vertical = {
				height = 0.8,
				preview_height = 0.5,
			},
		},
		mappings = {
			i = {
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,

				["<C-v>"] = actions.select_vertical,
				["<C-x>"] = actions.select_horizontal,
				["<C-t>"] = actions.select_tab,

				["<C-c>"] = actions.close,
				-- ["<Esc>"] = actions.close,

				["<C-u>"] = actions.preview_scrolling_up,
				["<C-d>"] = actions.preview_scrolling_down,
				["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
				["<Tab>"] = actions.toggle_selection,
				-- ["<C-r>"] = actions.refine_result,
			},
			n = {
				["<CR>"] = actions.select_default + actions.center,
				["<C-v>"] = actions.select_vertical,
				["<C-x>"] = actions.select_horizontal,
				["<C-t>"] = actions.select_tab,
				["<Esc>"] = actions.close,

				["j"] = actions.move_selection_next,
				["k"] = actions.move_selection_previous,

				["<C-u>"] = actions.preview_scrolling_up,
				["<C-d>"] = actions.preview_scrolling_down,
				["<C-q>"] = actions.send_to_qflist,
				["<Tab>"] = actions.toggle_selection,
			},
		},
	},
	pickers = {
		grep_string = dropdown({
			file_ignore_patterns = ignored_list,
		}),
		find_files = {
			file_ignore_patterns = ignored_list,
		},
		lsp_references = dropdown(),
		lsp_document_symbols = dropdown(),
		current_buffer_fuzzy_find = no_preview(),
	},
	extensions = {
		["ui-select"] = no_preview(),
		fzf = {
			override_generic_sorter = true,
			override_file_sorter = true,
		},
	},
})

telescope.load_extension("fzf") -- Sorter using fzf algorithm
telescope.load_extension("ui-select") -- vim.ui.select

local function builtins()
	require("telescope.builtin").builtin(no_preview())
end

local function workspace_symbols()
	require("telescope.builtin").lsp_workspace_symbols({
		path_display = { "smart" },
	})
end

local function grep_prompt()
	require("telescope.builtin").grep_string({
		path_display = { "smart" },
		search = vim.fn.input("Grep String > "),
		only_sort_text = true,
		use_regex = true,
	})
end

local map = vim.keymap.set

-- toggle telescope.nvim
map("n", "<C-p>", require("telescope.builtin").find_files, {
	desc = "Fuzzy find files using Telescope",
	noremap = true,
	silent = true,
})

map("n", "<C-f>", grep_prompt, {
	desc = "Fuzzy grep files using Telescope",
	noremap = true,
	silent = true,
})

map("n", "<Leader>ft", builtins, {
	desc = "Browse Telescope builtin pickers",
	noremap = true,
	silent = true,
})

map("n", "<Leader>fb", require("telescope.builtin").current_buffer_fuzzy_find, {
	desc = "Fuzzy grep current buffer content using Telescope",
	noremap = true,
	silent = true,
})

map("n", "<Leader>b", function()
	require("telescope.builtin").buffers({ initial_mode = "normal", ignore_current_buffer = true, sort_mru = true })
end, {
	desc = "Find Buffers",
	noremap = true,
	silent = true,
})