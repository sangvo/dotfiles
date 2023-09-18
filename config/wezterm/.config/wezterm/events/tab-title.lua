local wezterm = require("wezterm")

local M = {}

function prefix_tab_title(tab_title, tab_info)
  local tab_index = tab_info.tab_index + 1
  return '[' .. tab_index .. '] ' .. tab_title
end

function tab_title(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return tab_info.active_pane.title
end

M.setup = function()
  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local background = '#3c3836'
    local foreground = '#808080'

    if tab.is_active then
      background = '#1d2021'
      foreground = '#fabd2f'
    elseif hover then
      background = '#504945'
      foreground = '#909090'
    end

    local title = prefix_tab_title(tab_title(tab), tab)

    -- ensure that the titles fit in the available space,
    -- and that we have room for the edges.
    title = wezterm.truncate_right(title, max_width - 2)

    return {
      { Background = { Color = background } },
      { Foreground = { Color = foreground } },
      { Text = ' ' },
      { Text = title },
      { Text = ' ' },
    }
  end)
end

return M
