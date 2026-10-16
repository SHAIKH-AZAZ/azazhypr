------------------------------------------------------------
-- hyprexpo (sandwichfarm fork) - workspace overview grid
-- docs: https://hyprexpo.lol/docs/configuration/options
-- installed via: hyprpm add https://github.com/sandwichfarm/hyprexpo
------------------------------------------------------------
---@diagnostic disable: undefined-global

hl.config({
	plugin = {
		hyprexpo = {
			-- grid
			columns = 4,
			rows = 0, -- 0 = derive from columns
			gaps_in = 5,
			gaps_out = 10,
			bg_col = "rgb(11111b)",
			workspace_method = "center current",
			skip_empty = 0,
			show_cursor = 1,

			-- tiles
			tile_rounding = 10,
			border_width = 2,
			border_color_current = "rgb(66ccff)",
			border_color_focus = "rgb(ffcc66)",
			border_color_hover = "rgb(aabbcc)",

			-- labels
			label_enable = 1,
			label_text_mode = "id",
			label_position = "center",
			label_show = "always",
			label_font_family = "sans",
			label_font_size = 18,
			label_bg_enable = 1,
			label_bg_shape = "circle",

			-- keyboard nav: arrows/hjkl move, enter selects, escape cancels,
			-- number keys jump straight to that workspace
			keynav_enable = 1,
			number_key_mode = "workspace",
			keynav_wrap_h = 1,
			keynav_wrap_v = 1,
			cancel_key = "escape",

			-- touchpad: 0 = off, SystemSettings.lua already owns 3/4-finger swipes
			gesture_fingers = 0,
			gesture_direction = "up",
			gesture_distance = 200,
		},
	},
})

-- Plugin dispatchers are functions that fire immediately, so wrap them in a
-- closure for hl.bind (hl.dsp.* has no plugin equivalent).
hl.bind("SUPER + A", function()
	hl.plugin.hyprexpo.expo("toggle")
end, { description = "workspace overview (hyprexpo)" })

hl.bind("SUPER + CTRL + A", function()
	hl.plugin.hyprexpo.expo("toggle all")
end, { description = "workspace overview on all monitors" })
