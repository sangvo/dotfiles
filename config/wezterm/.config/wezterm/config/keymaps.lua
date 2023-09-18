local wezterm = require 'wezterm'
local act = wezterm.action
local config = {}

-- timeout_milliseconds defaults to 1000 and can be omitted
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
  {
    key = 'h',
    mods = 'ALT',
    action = wezterm.action.SplitPane({
      direction = "Down",
      size = { Percent = 25 },
    }),
  },
  {
    key = 'v',
    mods = 'ALT',
    action = wezterm.action.SplitPane({
      direction = "Right",
      size = { Percent = 35 },
    }),
  },
  {
    key = 'x',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane { confirm = true },
  },

  -- Navigation between panes
  {
    key = 'h',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.ActivatePaneDirection 'Left',
    },
    {
      key = 'l',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.ActivatePaneDirection 'Right',
    },
    {
      key = 'k',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.ActivatePaneDirection 'Up',
    },
    {
      key = 'j',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.ActivatePaneDirection 'Down',
    },

    {
      key = 'n',
      mods = 'SHIFT|CTRL',
      action = wezterm.action.ToggleFullScreen,
    },
    {
      key = 'f',
      mods = 'LEADER',
      action = wezterm.action.TogglePaneZoomState,
    },
}

for i = 1, 8 do
  -- CTRL+ALT + number to activate that tab
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'CTRL|ALT',
    action = act.ActivateTab(i - 1),
  })
end

return config
