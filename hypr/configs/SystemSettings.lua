-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
-- User settings
-- https://wiki.hypr.land/Configuring/Basics/Variables/
---@diagnostic disable: undefined-global

local home = assert(os.getenv("HOME"), "HOME environment variable is not available")

local scriptsDir = home .. "/.config/hypr/scripts"

------------------------------------------------------------
-- Main settings
------------------------------------------------------------

hl.config({
	--------------------------------------------------------
	-- Dwindle layout
	--------------------------------------------------------

	dwindle = {
		-- pseudotile = true,
		preserve_split = true,
		-- smart_split = true,
		special_scale_factor = 0.8,
	},

	--------------------------------------------------------
	-- Master layout
	--------------------------------------------------------

	master = {
		new_status = "master",
		new_on_top = true,
		mfact = 0.5,
	},

	--------------------------------------------------------
	-- General
	--------------------------------------------------------

	general = {
		resize_on_border = true,
		layout = "dwindle",
	},

	--------------------------------------------------------
	-- Input
	--------------------------------------------------------

	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		repeat_rate = 50,
		repeat_delay = 300,

		sensitivity = 0,

		-- accel_profile = "flat",

		numlock_by_default = true,
		left_handed = false,
		follow_mouse = 1,
		float_switch_override_focus = false,

		touchpad = {
			disable_while_typing = true,
			natural_scroll = true,
			clickfinger_behavior = false,
			middle_button_emulation = false,
			tap_to_click = true,

			-- drag_lock is an integer in current Hyprland:
			-- 0 = disabled
			-- 1 = enabled with timeout
			-- 2 = sticky
			drag_lock = 0,
		},

		touchdevice = {
			enabled = true,
		},

		tablet = {
			transform = 0,
			left_handed = false,
		},
	},

	--------------------------------------------------------
	-- Gesture behaviour
	--------------------------------------------------------

	gestures = {
		workspace_swipe_distance = 500,
		workspace_swipe_invert = true,
		workspace_swipe_min_speed_to_force = 30,
		workspace_swipe_cancel_ratio = 0.5,
		workspace_swipe_create_new = true,
		workspace_swipe_forever = true,

		-- workspace_swipe_use_r = true,
	},

	--------------------------------------------------------
	-- Miscellaneous
	--------------------------------------------------------

	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,

		-- vfr = true,
		vrr = 2,

		mouse_move_enables_dpms = true,

		enable_swallow = false,
		swallow_regex = "^(kitty)$",

		focus_on_activate = false,
		initial_workspace_tracking = 0,
		middle_click_paste = false,

		enable_anr_dialog = true,
		anr_missed_pings = 15,

		allow_session_lock_restore = true,

		-- 0: no change
		-- 1: focused window takes over fullscreen
		-- 2: focused window remains behind fullscreen
		on_focus_under_fullscreen = 1,
	},

	--------------------------------------------------------
	-- Keybind behaviour
	--------------------------------------------------------

	binds = {
		workspace_back_and_forth = true,
		allow_workspace_cycles = true,
		pass_mouse_when_bound = false,
	},

	--------------------------------------------------------
	-- XWayland
	--------------------------------------------------------

	xwayland = {
		enabled = true,
		force_zero_scaling = true,
	},

	--------------------------------------------------------
	-- Rendering
	--------------------------------------------------------

	render = {
		direct_scanout = 0,
	},

	--------------------------------------------------------
	-- Cursor
	--------------------------------------------------------

	cursor = {
		sync_gsettings_theme = true,
		no_hardware_cursors = 2,
		enable_hyprcursor = true,
		warp_on_change_workspace = 2,
		no_warps = true,
	},

	--------------------------------------------------------
	-- OpenGL
	--------------------------------------------------------

	-- opengl = {
	--     nvidia_anti_flicker = true,
	-- },
})

------------------------------------------------------------
-- Trackpad gestures
------------------------------------------------------------

-- Three-finger horizontal workspace swipe
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- Four-finger swipe up: zoom in
hl.gesture({
	fingers = 4,
	direction = "up",
	action = function()
		hl.exec_cmd([[
            hyprctl keyword cursor:zoom_factor "$(
                hyprctl getoption cursor:zoom_factor |
                awk 'NR==1 {
                    factor = $2;
                    if (factor < 1) {
                        factor = 1
                    };
                    print factor * 1.5
                }'
            )"
        ]])
	end,
})

-- Four-finger swipe down: zoom out
hl.gesture({
	fingers = 4,
	direction = "down",
	action = function()
		hl.exec_cmd([[
            hyprctl keyword cursor:zoom_factor "$(
                hyprctl getoption cursor:zoom_factor |
                awk 'NR==1 {
                    factor = $2;
                    if (factor < 1) {
                        factor = 1
                    };
                    print factor / 1.5
                }'
            )"
        ]])
	end,
})

-- Three-finger swipe up: desktop overview
hl.gesture({
	fingers = 3,
	direction = "up",
	action = function()
		hl.plugin.hyprexpo.expo("toggle")
	end,
})
