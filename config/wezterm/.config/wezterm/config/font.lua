local wezterm = require("wezterm")

-- initial size before events/font-size.lua picks one for the screen; Linux renders at 96 dpi
local font_size = wezterm.target_triple:find("darwin") and 13.5 or 11

return {
	font = wezterm.font({ family = "JetBrains Mono", weight = "Bold" }),
	font_size = font_size,
	line_height = 1.2,
	-- don't resize the window when font size changes (avoids a loop with events/font-size.lua)
	adjust_window_size_when_changing_font_size = false,
	freetype_load_flags = "NO_HINTING", -- smoother font,
	window_frame = {
		font_size = font_size,
	},
}
