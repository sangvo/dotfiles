local wezterm = require("wezterm")

-- same size events/font-size.lua picks for the screen, so a new window doesn't jump in size
local font_size = require("events.font-size").initial_size()

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
