------------------------------------------------------------
-- Hyprdrive - Mission Control + Dock
-- https://github.com/dragosol/Hyprdrive
------------------------------------------------------------
---@diagnostic disable: undefined-global

-- Guarded like the binds below: at boot this file parses before hyprpm loads
-- the plugin, so the keys would be unknown. Startup re-parses after load.
if hl.plugin.hyprdrive then
	hl.config({
		plugin = {
			hyprdrive = {
				-- Overview
				mission_control = true,
				mission_control_gap = 30,
				scale = 0.82,
				workspace_gap = 30,
				strip = true,
				strip_height = 220,
				tap_super = false,

				-- Animations
				open_speed = 2.6,
				close_speed = 1.9,

				-- Dock
				dock = {
					enabled = true,
					autohide = true,
					icon_size = 54,
					corner_radius = 20,
					running_indicator = true,
					show_favorites = true,
					show_apps_button = true,
				},
			},
		},
	})
end

------------------------------------------------------------
-- Keybindings
------------------------------------------------------------

-- Guarded: if the plugin fails to load, hl.plugin.hyprdrive is nil and an
-- unguarded line would stop Hyprland registering ANY bind.
-- SUPER+TAB / SUPER+H / SUPER+COMMA are taken (next workspace, cheat sheet,
-- previous workspace), so the overview takes hyprexpo's old SUPER+A.
if hl.plugin.hyprdrive then
	hl.bind("SUPER + A", hl.plugin.hyprdrive.overview("toggle"), { description = "overview (hyprdrive)" })
	hl.bind("SUPER + CTRL + A", hl.plugin.hyprdrive.overview("toggle all"), { description = "overview on all monitors" })
	hl.bind("SUPER + CTRL + M", hl.plugin.hyprdrive.minimize("window"), { description = "minimize window to dock" })
	hl.bind("SUPER + SHIFT + COMMA", hl.plugin.hyprdrive.settings(), { description = "hyprdrive settings" })

	-- click a window in the overview to pick it (from the plugin's 30-keybinds.lua;
	-- hyprpm installs only the .so, not those fragments)
	hl.define_submap("hyprdrive", function()
		hl.bind("mouse:272", hl.plugin.hyprdrive.window([[click]]), { mouse = true, description = "Overview: select" })
		hl.bind("SUPER + mouse:272", hl.plugin.hyprdrive.window([[click]]), { mouse = true, description = "Overview: select (SUPER held)" })
	end)

	-- 3-finger swipe up/down opens/closes the overview (replaces the hyprexpo gesture)
	hl.plugin.hyprdrive.gesture({ fingers = 3, direction = "up" })
	hl.plugin.hyprdrive.gesture({ fingers = 3, direction = "down" })
end
