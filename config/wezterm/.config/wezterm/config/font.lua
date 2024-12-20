local wezterm = require("wezterm")

return {
	font = wezterm.font({ family = "JetBrains Mono", weight = "Bold" }),
	font_size = 10.5,
	freetype_load_flags = "NO_HINTING", -- smoother font
}
