local wezterm = require("wezterm")

return {
	font = wezterm.font({ family = "JetBrains Mono", weight = "Bold" }),
	font_size = 13,
	line_height = 1.2,
	freetype_load_flags = "NO_HINTING", -- smoother font,
	window_frame = {
		font_size = 13.0,
	},
}
