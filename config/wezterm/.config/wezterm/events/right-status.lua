local wezterm = require 'wezterm'

local M = {}

M.setup = function()
  wezterm.on("update-right-status", function(window, pane)

    local status = wezterm.format({
	      {Foreground={Color="#5e8052"}},
      	{Background={Color="#3c3836"}},
      	{Text=""},
      	{Foreground={Color="#1d2021"}},
      	{Background={Color="#5e8052"}},
      	{Text="Full Stuck Developer"},
    })
    window:set_right_status(status)
  end)
end

return M
