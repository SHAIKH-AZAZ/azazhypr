local config = require("config")
local h = require("lib")

local p = config.paths
local mod = "$mainMod"

return {
	h.var("$mainMod", config.defaults.main_mod),
	h.var("$scriptsDir", p.scripts),
	h.var("$UserScripts", p.user_scripts),
	h.var("$UserConfigs", p.user_configs),

	h.blank(),
	h.comment("Common shortcuts"),
	h.bind({
		mod = mod,
		key = "D",
		description = "app launcher",
		dispatcher = "exec",
		arg = "pkill rofi || true && rofi -show drun -modi drun,filebrowser,run,window",
	}),
	h.bind({
		mod = mod,
		key = "B",
		description = "open default browser",
		dispatcher = "exec",
		arg = 'xdg-open "https://"',
	}),
	h.bind({
		mod = mod,
		key = "A",
		description = "desktop overview",
		dispatcher = "exec",
		arg = "$scriptsDir/OverviewToggle.sh",
	}),
	h.bind({ mod = mod, key = "Return", description = "Open terminal", dispatcher = "exec", arg = "$term" }),
	h.bind({ mod = mod, key = "E", description = "file manager", dispatcher = "exec", arg = "$files" }),

	h.blank(),
	h.comment("Wallpaper and theme"),
	h.bind({
		mod = mod,
		key = "T",
		description = "Global theme switcher using Wallust",
		dispatcher = "exec",
		arg = "$scriptsDir/ThemeChanger.sh",
	}),
	h.bind({
		mod = mod,
		key = "W",
		description = "select wallpaper",
		dispatcher = "exec",
		arg = "$UserScripts/WallpaperSelect.sh",
	}),
	h.bind({
		mod = mod .. " SHIFT",
		key = "W",
		description = "wallpaper effects",
		dispatcher = "exec",
		arg = "$UserScripts/WallpaperEffects.sh",
	}),
	h.bind({
		mod = "CTRL ALT",
		key = "W",
		description = "random wallpaper",
		dispatcher = "exec",
		arg = "$UserScripts/WallpaperRandom.sh",
	}),

	h.blank(),
	h.comment("Window controls"),
	h.bind({ mod = mod .. " SHIFT", key = "F", description = "fullscreen", dispatcher = "fullscreen" }),
	h.bind({ mod = mod .. " CTRL", key = "F", description = "maximize window", dispatcher = "fullscreen", arg = "1" }),
	h.bind({ mod = mod, key = "SPACE", description = "Float current window", dispatcher = "togglefloating" }),
	h.bind({ mod = mod, key = "Q", description = "close active window", dispatcher = "killactive" }),
	h.bind({
		mod = mod .. " SHIFT",
		key = "Q",
		description = "Terminate active process",
		dispatcher = "exec",
		arg = "$scriptsDir/KillActiveProcess.sh",
	}),

	h.blank(),
	h.comment("System"),
	h.bind({
		mod = "CTRL ALT",
		key = "Delete",
		description = "exit Hyprland",
		dispatcher = "exec",
		arg = "hyprctl dispatch exit 0",
	}),
	h.bind({
		mod = "CTRL ALT",
		key = "L",
		description = "lock screen",
		dispatcher = "exec",
		arg = "$scriptsDir/LockScreen.sh",
	}),
	h.bind({
		mod = "CTRL ALT",
		key = "P",
		description = "powermenu",
		dispatcher = "exec",
		arg = "$scriptsDir/Wlogout.sh",
	}),

	h.blank(),
	h.comment("Focus"),
	h.bind({ mod = mod, key = "left", description = "focus left", dispatcher = "movefocus", arg = "l" }),
	h.bind({ mod = mod, key = "right", description = "focus right", dispatcher = "movefocus", arg = "r" }),
	h.bind({ mod = mod, key = "up", description = "focus up", dispatcher = "movefocus", arg = "u" }),
	h.bind({ mod = mod, key = "down", description = "focus down", dispatcher = "movefocus", arg = "d" }),

	h.blank(),
	h.comment("Workspaces"),
	h.bind({ mod = mod, key = "tab", description = "next workspace", dispatcher = "workspace", arg = "m+1" }),
	h.bind({
		mod = mod .. " SHIFT",
		key = "tab",
		description = "previous workspace",
		dispatcher = "workspace",
		arg = "m-1",
	}),
	h.bind({ mod = mod, key = "code:10", description = "workspace 1", dispatcher = "workspace", arg = "1" }),
	h.bind({ mod = mod, key = "code:11", description = "workspace 2", dispatcher = "workspace", arg = "2" }),
	h.bind({ mod = mod, key = "code:12", description = "workspace 3", dispatcher = "workspace", arg = "3" }),
	h.bind({ mod = mod, key = "code:13", description = "workspace 4", dispatcher = "workspace", arg = "4" }),
	h.bind({ mod = mod, key = "code:14", description = "workspace 5", dispatcher = "workspace", arg = "5" }),
	h.bind({ mod = mod, key = "code:15", description = "workspace 6", dispatcher = "workspace", arg = "6" }),
	h.bind({ mod = mod, key = "code:16", description = "workspace 7", dispatcher = "workspace", arg = "7" }),
	h.bind({ mod = mod, key = "code:17", description = "workspace 8", dispatcher = "workspace", arg = "8" }),
	h.bind({ mod = mod, key = "code:18", description = "workspace 9", dispatcher = "workspace", arg = "9" }),
	h.bind({ mod = mod, key = "code:19", description = "workspace 10", dispatcher = "workspace", arg = "10" }),

	h.blank(),
	h.comment("HyprExpo"),

	hl.bind("SUPER + A", function()
		hl.plugin.hyprexpo.expo("toggle")
	end),

	h.comment("Mouse"),
	h.bind({
		bind_type = "bindmd",
		mod = mod,
		key = "mouse:272",
		description = "move window",
		dispatcher = "movewindow",
	}),
	h.bind({
		bind_type = "bindmd",
		mod = mod,
		key = "mouse:273",
		description = "resize window",
		dispatcher = "resizewindow",
	}),
}
