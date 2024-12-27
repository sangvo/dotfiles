local wezterm = require("wezterm")
local mux = wezterm.mux

local M = {}

M.setup = function()
	wezterm.on("gui-startup", function(cmd)
		local tab, pane, window = mux.spawn_window(cmd or {})
		local project_dir = wezterm.home_dir .. "/workspace"
		pane:split({ direction = "Bottom", size = 0.3 })
	end)
end

return M
