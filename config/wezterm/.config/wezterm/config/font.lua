local wezterm = require 'wezterm'

return {
  font = wezterm.font 'JetBrains Mono',
  font_size = 10.5,
  freetype_load_flags = "NO_HINTING", -- smoother font
}
