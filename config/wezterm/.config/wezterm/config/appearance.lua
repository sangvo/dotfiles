local wezterm = require("wezterm")

-- On X11 wezterm sends the same "border" motif hint for RESIZE and INTEGRATED_BUTTONS, and
-- GNOME (mutter) draws its whole title bar for it; only NONE removes the title bar there
local window_decorations = wezterm.target_triple:find("darwin") and "RESIZE|INTEGRATED_BUTTONS" or "NONE"

return {
	color_scheme = "rose-pine-moon",

	window_background_opacity = 0.85,
	macos_window_background_blur = 10,

	window_decorations = window_decorations,
	use_fancy_tab_bar = true,
	enable_scroll_bar = true,

	initial_cols = 200,
	initial_rows = 60,

	show_tab_index_in_tab_bar = false,
	switch_to_last_active_tab_when_closing_tab = true,
	colors = {
		selection_fg = "none",
		selection_bg = "rgba:50% 50% 50% 50%",
	},
}
