local wezterm = require("wezterm")

local M = {}

M.setup = function()
	wezterm.on("update-right-status", function(window, _pane)
		local status = wezterm.format({
			{ Text = "💛 ⭐ 💜" },
		})
		window:set_right_status(status)
	end)
end

return M
