local wezterm = require("wezterm")
local mux = wezterm.mux

local M = {}

M.setup = function()
	wezterm.on("gui-startup", function(cmd)
		local tab, pane, window = mux.spawn_window(cmd or {})
		window:gui_window():maximize()
		local args = {}
		if cmd then
			args = cmd.args
		end
		local project_dir = wezterm.home_dir .. "/company/atlaport-ci"
		mux.spawn_window({
			workspace = "work",
			cwd = project_dir,
			args = args,
		})
		mux.set_active_workspace("work")
	end)
end

return M
