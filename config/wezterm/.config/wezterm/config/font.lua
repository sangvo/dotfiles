local wezterm = require 'wezterm'

return {
  font = wezterm.font 'JetBrains Mono',
  font_size = 13,
  freetype_load_flags = "NO_HINTING", -- smoother font
}
