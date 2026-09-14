local wezterm = require 'wezterm'
local act = wezterm.action
local config = {}

-- LEADER = prefix tmux (C-a), timeout 1s
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

-- same as tmux's is_vim: g?(view|n?vim?x?)(diff)?
local vim_names = {
  vi = true, vim = true, nvim = true, vimx = true, gvim = true, view = true,
  vimdiff = true, nvimdiff = true,
}

local function is_vim(pane)
  local name = (pane:get_foreground_process_name() or ''):match('([^/\\]+)$') or ''
  return vim_names[name] == true
end

-- C-h/j/k/l: in vim, pass the key through to vim-tmux-navigator;
-- with no pane in that direction, pass it to the shell (e.g. C-l clear); otherwise switch pane
local function navigate(key, direction)
  return {
    key = key,
    mods = 'CTRL',
    action = wezterm.action_callback(function(window, pane)
      local send = act.SendKey { key = key, mods = 'CTRL' }
      if is_vim(pane) then
        return window:perform_action(send, pane)
      end
      local ok, neighbor = pcall(function()
        return pane:tab():get_pane_direction(direction)
      end)
      if ok and not neighbor then
        return window:perform_action(send, pane)
      end
      window:perform_action(act.ActivatePaneDirection(direction), pane)
    end),
  }
end

-- LEADER + H/J/K/L resizes, keep pressing H/J/K/L to repeat (like tmux's bind -r)
local function resize(key, direction)
  return {
    key = key,
    mods = 'LEADER|SHIFT',
    action = act.Multiple {
      act.AdjustPaneSize { direction, 4 },
      act.ActivateKeyTable { name = 'resize_pane', one_shot = false, until_unknown = true },
    },
  }
end

config.keys = {
  -- ===== Split =====
  { key = 'h', mods = 'ALT', action = act.SplitPane { direction = 'Down', size = { Percent = 25 } } },
  { key = 'v', mods = 'ALT', action = act.SplitPane { direction = 'Right', size = { Percent = 35 } } },
  -- tmux: | - (active config) and v s (dotfiles config)
  { key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'v', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 's', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  -- tmux: T bottom panel 10 rows, P right panel 30%
  { key = 't', mods = 'LEADER|SHIFT', action = act.SplitPane { direction = 'Down', size = { Cells = 10 } } },
  { key = 'p', mods = 'LEADER|SHIFT', action = act.SplitPane { direction = 'Right', size = { Percent = 30 } } },
  -- kitty: cmd+d / cmd+shift+d
  { key = 'd', mods = 'CMD', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- ===== Pane =====
  { key = 'x', mods = 'CMD', action = act.CloseCurrentPane { confirm = true } },
  { key = 'h', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Right' },
  { key = 'k', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Up' },
  { key = 'j', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Down' },
  -- tmux: LEADER h/j/k/l
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
  -- tmux + vim-tmux-navigator: C-h/j/k/l
  navigate('h', 'Left'),
  navigate('j', 'Down'),
  navigate('k', 'Up'),
  navigate('l', 'Right'),
  resize('h', 'Left'),
  resize('j', 'Down'),
  resize('k', 'Up'),
  resize('l', 'Right'),
  -- zoom: LEADER f (tmux), cmd+enter (kitty)
  { key = 'f', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'Enter', mods = 'CMD', action = act.TogglePaneZoomState },
  -- tmux: > < swap pane
  { key = '>', mods = 'LEADER|SHIFT', action = act.RotatePanes 'Clockwise' },
  { key = '<', mods = 'LEADER|SHIFT', action = act.RotatePanes 'CounterClockwise' },

  -- ===== Tab (tmux window) =====
  -- kitty's cmd+t / cmd+w / cmd+shift+[ ] are already WezTerm defaults
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'p', mods = 'LEADER|CTRL', action = act.ActivateTabRelative(-1) },
  { key = 'n', mods = 'LEADER|CTRL', action = act.ActivateTabRelative(1) },
  { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(-1) },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(1) },
  {
    key = ',',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Rename tab',
      action = wezterm.action_callback(function(window, _, line)
        if line and #line > 0 then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  -- ===== Workspace (tmux session) =====
  { key = 'w', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  {
    key = 'c',
    mods = 'LEADER|SHIFT',
    action = act.PromptInputLine {
      description = 'New workspace',
      action = wezterm.action_callback(function(window, pane, line)
        if line and #line > 0 then
          window:perform_action(act.SwitchToWorkspace { name = line }, pane)
        end
      end),
    },
  },

  -- ===== Copy / search =====
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
  { key = '/', mods = 'LEADER', action = act.Search 'CurrentSelectionOrEmptyString' },

  -- ===== Misc =====
  -- tmux: C-a C-a sends C-a (beginning of line in zsh)
  { key = 'a', mods = 'LEADER|CTRL', action = act.SendKey { key = 'a', mods = 'CTRL' } },
  { key = 'r', mods = 'LEADER', action = act.ReloadConfiguration },
  { key = 'r', mods = 'CMD|SHIFT', action = act.ReloadConfiguration },
  {
    key = ',',
    mods = 'CMD',
    action = act.SpawnCommandInNewTab {
      args = { os.getenv('SHELL') or '/bin/zsh', '-ic', 'nvim wezterm.lua' },
      cwd = wezterm.home_dir .. '/.config/wezterm',
    },
  },
  { key = 'n', mods = 'SHIFT|CTRL', action = act.ToggleFullScreen },
}

config.key_tables = {
  resize_pane = {
    { key = 'h', mods = 'SHIFT', action = act.AdjustPaneSize { 'Left', 4 } },
    { key = 'j', mods = 'SHIFT', action = act.AdjustPaneSize { 'Down', 4 } },
    { key = 'k', mods = 'SHIFT', action = act.AdjustPaneSize { 'Up', 4 } },
    { key = 'l', mods = 'SHIFT', action = act.AdjustPaneSize { 'Right', 4 } },
    { key = 'Escape', action = 'PopKeyTable' },
  },
}

for i = 1, 9 do
  -- CTRL+ALT + number (existing) and LEADER + number (tmux, base-index 1)
  table.insert(config.keys, { key = tostring(i), mods = 'CTRL|ALT', action = act.ActivateTab(i - 1) })
  table.insert(config.keys, { key = tostring(i), mods = 'LEADER', action = act.ActivateTab(i - 1) })
end

return config
