local wezterm = require("wezterm")
local mux = wezterm.mux

local M = {}

M.setup = function()
	wezterm.on("gui-startup", function(cmd)
		local _, pane = mux.spawn_window(cmd or {})
		pane:split({ direction = "Bottom", size = 0.3 })
	end)
end

return M
