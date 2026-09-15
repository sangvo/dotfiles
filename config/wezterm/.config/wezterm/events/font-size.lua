local wezterm = require("wezterm")

local M = {}

local is_mac = wezterm.target_triple:find("darwin") ~= nil

-- dpi of one logical pixel: macOS renders points at 72 dpi, Linux (X11/Wayland) at 96 dpi,
-- so the same font_size is ~1.33x larger on Linux
local BASE_DPI = is_mac and 72 or 96

-- base font size (window near full width) by the screen's logical width
-- (macOS: System Settings > Displays > "Looks like"; Linux: resolution / display scale)
local screen_sizes = is_mac
		and {
			{ max_width = 1800, size = 13.5 }, -- MacBook
			{ max_width = 2200, size = 12 }, -- 4K scaled 1920x1080 (text already large)
			{ max_width = 2600, size = 13.5 }, -- 5K / 4K scaled 2560x1440
			{ max_width = math.huge, size = 15 }, -- 4K native 3008/3840 (text small)
		}
	or {
		{ max_width = 2200, size = 11 }, -- 1920x1080 (24")
		{ max_width = 2600, size = 12 }, -- 2560x1440
		{ max_width = math.huge, size = 13 }, -- 4K unscaled
	}

-- the narrower the window relative to the screen, the smaller the font
-- min_ratio = window width / screen width
local window_steps = {
	{ min_ratio = 0.6, delta = 0 },
	{ min_ratio = 0.35, delta = -1 },
	{ min_ratio = 0, delta = -2 },
}

-- hysteresis band around thresholds so the size doesn't flip-flop when resizing near one
local HYSTERESIS = 0.05
local MIN_SIZE = 10

local function base_size_for(logical_width)
	for _, s in ipairs(screen_sizes) do
		if logical_width <= s.max_width then
			return s.size
		end
	end
end

local function step_for(ratio, offset)
	for i, s in ipairs(window_steps) do
		if s.min_ratio == 0 or ratio >= s.min_ratio + offset then
			return i
		end
	end
end

local function pick_step(ratio, current)
	if not current then
		return step_for(ratio, 0)
	end
	local up = step_for(ratio, HYSTERESIS) -- must clearly pass the threshold to grow
	local down = step_for(ratio, -HYSTERESIS) -- must clearly drop below the threshold to shrink
	if up < current then
		return up
	elseif down > current then
		return down
	end
	return current
end

local function apply(window)
	local screen = wezterm.gui.screens().active
	local dim = window:get_dimensions()
	local dpi = screen.effective_dpi or dim.dpi
	local base = base_size_for(screen.width / (dpi / BASE_DPI))

	-- GLOBAL survives config reloads (set_config_overrides triggers a reload)
	local key = "font_step_" .. window:window_id()
	local step = pick_step(dim.pixel_width / screen.width, wezterm.GLOBAL[key])
	wezterm.GLOBAL[key] = step

	local size = math.max(MIN_SIZE, base + window_steps[step].delta)
	local overrides = window:get_config_overrides() or {}
	if overrides.font_size ~= size then
		overrides.font_size = size
		overrides.window_frame = { font_size = size }
		window:set_config_overrides(overrides)
	end
end

M.setup = function()
	-- config-reloaded fires when a window opens, resized catches resizing / moving to a screen with different DPI
	wezterm.on("window-config-reloaded", apply)
	wezterm.on("window-resized", apply)
end

return M
