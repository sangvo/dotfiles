local wezterm = require 'wezterm'

return {
  color_scheme = 'rose-pine-moon',

  window_decorations = 'RESIZE',
  use_fancy_tab_bar = false,

  show_tab_index_in_tab_bar = false,
  switch_to_last_active_tab_when_closing_tab = true,

  colors = {
    tab_bar = {
      background = '#393552',
      new_tab = {
        bg_color = '#393552',
	      fg_color = '#e0def4'
      }
    },
    selection_bg = '#fffacd',
    selection_fg = 'black',
  },
}
