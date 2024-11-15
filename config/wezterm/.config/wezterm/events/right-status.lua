local wezterm = require("wezterm")

local M = {}

M.setup = function()
	wezterm.on("update-right-status", function(window, pane)
		local status = wezterm.format({
			{ Foreground = { Color = "#797593" } },
			{ Background = { Color = "#3c3836" } },
			{ Text = "" },
			{ Foreground = { Color = "#dfdad9" } },
			{ Background = { Color = "#797593" } },
			{ Text = "     󰮯 " },

			{ Foreground = { Color = "#d7827e" } },
			{ Background = { Color = "#797593" } },
			{ Text = "" },
			{ Foreground = { Color = "#dfdad9" } },
			{ Background = { Color = "#d7827e" } },
			{ Text = "  SANG-VO   " },
		})
		window:set_right_status(status)
	end)
end

return M
