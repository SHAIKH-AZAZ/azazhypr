-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
-- Default Keybinds converted to Hyprland Lua (0.55+)
-- https://wiki.hypr.land/Configuring/Basics/Binds/

local home = assert(os.getenv("HOME"), "HOME environment variable is not set")

-- Windows key as supper Key
local mainMod = "SUPER"
local scriptsDir = home .. "/.config/hypr/scripts"
local userScripts = home .. "/.config/hypr/UserScripts"

-- User default applications.
-- UserConfigs/01-UserDefaults.lua should return a table, for example:
-- return { term = "kitty", files = "thunar" }
local defaults = require("UserConfigs.01-UserDefaults")
assert(type(defaults) == "table", "UserConfigs/01-UserDefaults.lua must return a table")

local term = defaults.term or defaults.terminal
local files = defaults.files or defaults.fileManager or defaults.file_manager

assert(type(term) == "string" and term ~= "", "Missing 'term' in UserConfigs/01-UserDefaults.lua")
assert(type(files) == "string" and files ~= "", "Missing 'files' in UserConfigs/01-UserDefaults.lua")

--- Helper function
---@diagnostic disable: undefined-global
local function bind(keys, dispatcher, description, flags)
	flags = flags or {}
	if description then
		flags.description = description
	end
	return hl.bind(keys, dispatcher, flags)
end

local function exec(command)
	return hl.dsp.exec_cmd(command)
end

------------------------------------------------------------
-- Standard / common shortcuts
------------------------------------------------------------

-- Super-key release launcher:
-- bind(mainMod .. " + SUPER_L",
--     exec("pkill rofi || rofi -show drun -modi drun,filebrowser,run,window"),
--     nil,
--     { release = true }
-- )

bind(mainMod .. " + D", exec("rofi -show"), "app launcher")

bind(mainMod .. " + B", exec([[xdg-open "https://"]]), "open default browser")

-- SUPER + A now opens the hyprdrive overview (plugins/hyprdrive.lua).
-- bind(mainMod .. " + A", exec(scriptsDir .. "/OverviewToggle.sh"), "desktop overview")

-- AGS overview alternative:
-- bind(mainMod .. " + A",
--     exec([[pkill rofi || true && ags -t 'overview']]),
--     "ags overview"
-- )

-- Quickshell global shortcut alternative:
-- bind(mainMod .. " + A",
--     hl.dsp.global("quickshell:overviewToggle"),
--     "Quickshell overview"
-- )

bind(mainMod .. " + Return", exec(term), "Open terminal")
bind(mainMod .. " + E", exec(files), "file manager")

------------------------------------------------------------
-- Features / extras
------------------------------------------------------------

bind(mainMod .. " + T", exec(scriptsDir .. "/ThemeChanger.sh"), "Global theme switcher using Wallust")

bind(mainMod .. " + H", exec(scriptsDir .. "/KeyHints.sh"), "help / cheat sheet")

bind(mainMod .. " + ALT + R", exec(scriptsDir .. "/Refresh.sh"), "refresh bar and menus")

bind(mainMod .. " + ALT + E", exec(scriptsDir .. "/RofiEmoji.sh"), "emoji menu")

bind(mainMod .. " + S", exec(scriptsDir .. "/RofiSearch.sh"), "web search")

bind(mainMod .. " + CTRL + S", exec("rofi -show window"), "window switcher")

bind(mainMod .. " + ALT + O", exec(scriptsDir .. "/ChangeBlur.sh"), "toggle blur")

bind(mainMod .. " + SHIFT + G", exec(scriptsDir .. "/GameMode.sh"), "toggle game mode")

bind(mainMod .. " + ALT + L", exec(scriptsDir .. "/ChangeLayout.sh"), "toggle master/dwindle layout")

bind(
	mainMod .. " + ALT + V",
	exec("qs ipc call island open clipboard"),
	"clipboard manager"
)

bind(
	mainMod .. " + SHIFT + P",
	exec(scriptsDir .. "/ScreenShot.sh --area"), -- was bar screenshot menu
	"screenshot menu"
)

bind(mainMod .. " + CTRL + R", exec(scriptsDir .. "/RofiThemeSelector.sh"), "rofi theme selector")

bind(
	mainMod .. " + CTRL + SHIFT + R",
	exec("pkill rofi || true && " .. scriptsDir .. "/RofiThemeSelector-modified.sh"),
	"rofi theme selector (modified)"
)

------------------------------------------------------------
-- Window state
------------------------------------------------------------

bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), "fullscreen")

bind(mainMod .. " + CTRL + F", hl.dsp.window.fullscreen({ mode = "maximized" }), "maximize window")

bind(mainMod .. " + SPACE", hl.dsp.window.float({ action = "toggle" }), "Float current window")

-- Float + center at 74% x 75% of the monitor (toggles back to tiled when already floating).
bind(mainMod .. " + ALT + Return", exec(scriptsDir .. "/FloatCenter.sh"), "Float window centered (large)")

bind(mainMod .. " + SHIFT + SPACE", function()
	hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
	hl.dispatch(hl.dsp.window.resize({ x = 600, y = 300, relative = true }))
	hl.dispatch(hl.dsp.window.center())
end, "Floating popup center")

-- There is no workspaceopt dispatcher in the Lua API, and `hyprctl dispatch` now
-- evaluates lua, so the old command form silently errored. Float every window on
-- the active workspace instead: any tiled window -> float all, otherwise unfloat all.
-- Correct signature: hl.bind(keys, function, flags_table)
hl.bind(mainMod .. " + ALT + SPACE", function()
	local active_ws = hl.get_active_workspace()
	if not active_ws then
		return
	end

	local windows = hl.get_workspace_windows(active_ws.id)
	local action = "disable"

	for _, w in ipairs(windows) do
		if not w.floating then
			action = "enable"
			break
		end
	end

	for _, w in ipairs(windows) do
		hl.dispatch(hl.dsp.window.float({ action = action, window = "address:" .. w.address }))
	end
end, { description = "Float all windows" })

bind(mainMod .. " + SHIFT + Return", exec(scriptsDir .. "/Dropterminal.sh " .. term), "DropDown terminal")

------------------------------------------------------------
-- Desktop zoom / magnifier
------------------------------------------------------------

bind(
	mainMod .. " + ALT + mouse_down",
	exec(
		[[hyprctl keyword cursor:zoom_factor "$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor * 2.0}')"]]
	),
	"zoom in"
)

bind(
	mainMod .. " + ALT + mouse_up",
	exec(
		[[hyprctl keyword cursor:zoom_factor "$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor / 2.0}')"]]
	),
	"zoom out"
)

------------------------------------------------------------
-- Waybar / bar
------------------------------------------------------------

-- bind(
-- 	mainMod .. " + CTRL + ALT + B",
-- 	exec("qs -p /home/azaz/.config/quickshell/bar ipc call bar toggle"),
-- 	"toggle bar on/off"
-- )

bind(mainMod .. " + ALT + B", exec(scriptsDir .. "/WaybarLayout.sh"), "waybar layout menu")

------------------------------------------------------------
-- Night light
------------------------------------------------------------

bind(mainMod .. " + N", exec(scriptsDir .. "/Hyprsunset.sh toggle"), "toggle night light")

------------------------------------------------------------
-- User scripts
------------------------------------------------------------

bind(mainMod .. " + SHIFT + M", exec(userScripts .. "/RofiBeats.sh"), "online music")

bind(
	mainMod .. " + W",
	exec(userScripts .. "/WallpaperSelect.sh"),
	"select wallpaper"
)

bind(mainMod .. " + SHIFT + W", exec(userScripts .. "/WallpaperEffects.sh"), "wallpaper effects")

bind("CTRL + ALT + W", exec(userScripts .. "/WallpaperRandom.sh"), "random wallpaper")

bind(
	mainMod .. " + CTRL + O",
	hl.dsp.window.set_prop({ prop = "opaque", value = "toggle" }),
	"toggle active window opacity"
)

bind(mainMod .. " + SHIFT + K", exec(scriptsDir .. "/KeyBinds.sh"), "search keybinds")

bind(mainMod .. " + SHIFT + A", exec(scriptsDir .. "/Animations.sh"), "animations menu")

bind(mainMod .. " + SHIFT + O", exec(userScripts .. "/ZshChangeTheme.sh"), "change oh-my-zsh theme")

bind(
	"ALT_L + SHIFT_L",
	exec(scriptsDir .. "/KeyboardLayout.sh switch"),
	"switch keyboard layout globally",
	{ locked = true, non_consuming = true }
)

bind(
	"SHIFT_L + ALT_L",
	exec(scriptsDir .. "/Tak0-Per-Window-Switch.sh"),
	"switch keyboard layout per-window",
	{ locked = true, non_consuming = true }
)

bind(mainMod .. " + ALT + C", exec(userScripts .. "/RofiCalc.sh"), "calculator")

------------------------------------------------------------
-- Move current workspace to another monitor
------------------------------------------------------------

local monitorDirections = {
	{ key = "F9", direction = "l", description = "move workspace to left monitor" },
	{ key = "F10", direction = "r", description = "move workspace to right monitor" },
	{ key = "F11", direction = "u", description = "move workspace to up monitor" },
	{ key = "F12", direction = "d", description = "move workspace to down monitor" },
}

for _, item in ipairs(monitorDirections) do
	bind(mainMod .. " + CTRL + " .. item.key, hl.dsp.workspace.move({ monitor = item.direction }), item.description)
end

------------------------------------------------------------
-- System
------------------------------------------------------------

bind("CTRL + ALT + Delete", hl.dsp.exit(), "exit Hyprland")

bind(mainMod .. " + Q", hl.dsp.window.close(), "close active window")

bind(mainMod .. " + SHIFT + Q", exec(scriptsDir .. "/KillActiveProcess.sh"), "Terminate active process")

bind("CTRL + ALT + L", exec(scriptsDir .. "/LockScreen.sh"), "lock screen")

bind("CTRL + ALT + P", exec(scriptsDir .. "/Wlogout.sh"), "powermenu")

bind(
	mainMod .. " + SHIFT + N",
	exec("qs ipc call notifications toggleDnd"),
	"toggle do-not-disturb"
)

bind(mainMod .. " + SHIFT + E", exec(scriptsDir .. "/Kool_Quick_Settings.sh"), "Quick settings menu")

------------------------------------------------------------
-- Master layout
------------------------------------------------------------

-- Master-only layoutmsgs (addmaster/removemaster/swapwithmaster/cycleprev) raise
-- "Unknown dwindle layoutmsg" when the active layout is dwindle. hyprctl keyword is
-- rejected under the lua parser, so ChangeLayout.sh cannot rebind these per layout;
-- instead each bind picks its dispatcher at press time.
local function is_master()
	return hl.get_config("general:layout") == "master"
end

-- master_msg under master, dwindle_msg under dwindle (nil dwindle_msg = no-op).
local function layoutmsg(master_msg, dwindle_msg)
	return function()
		local msg = is_master() and master_msg or dwindle_msg
		if msg then
			hl.dispatch(hl.dsp.layout(msg))
		end
	end
end

-- Master cycles through the layout; dwindle has no cycle layoutmsg, so use the
-- global window cycler there.
local function cycle(prev)
	return function()
		if is_master() then
			hl.dispatch(hl.dsp.layout(prev and "cycleprev" or "cyclenext"))
		else
			hl.dispatch(hl.dsp.window.cycle_next({ prev = prev }))
		end
	end
end

bind(mainMod .. " + CTRL + D", layoutmsg("removemaster"), "remove master")
bind(mainMod .. " + I", layoutmsg("addmaster"), "add master")
bind(mainMod .. " + J", cycle(false), "cycle next")
bind(mainMod .. " + K", cycle(true), "cycle previous")
bind(mainMod .. " + CTRL + Return", layoutmsg("swapwithmaster", "swapsplit"), "swap window")

------------------------------------------------------------
-- Dwindle layout
------------------------------------------------------------

-- bind(mainMod .. " + SHIFT + I",
--     hl.dsp.layout("togglesplit"),
--     "toggle split (dwindle)"
-- )

bind(mainMod .. " + P", hl.dsp.window.pseudo({ action = "toggle" }), "toggle pseudo (dwindle)")

-- Preserve the old command's relative +0.3 split-ratio behavior.
bind(mainMod .. " + M", hl.dsp.layout("splitratio 0.3"), "set split ratio 0.3")

-- Old: exec-once = $scriptsDir/ChangeLayout.sh init
hl.on("hyprland.start", function()
	hl.exec_cmd(scriptsDir .. "/ChangeLayout.sh init")
end)

------------------------------------------------------------
-- Cycle windows; raise floating window
------------------------------------------------------------

bind("ALT + Tab", hl.dsp.window.cycle_next({ next = true }), "cycle next window")

bind("ALT + Tab", hl.dsp.window.alter_zorder({ mode = "top" }), "bring active to top")

------------------------------------------------------------
-- Special keys / hotkeys
------------------------------------------------------------

bind("XF86AudioRaiseVolume", exec(scriptsDir .. "/Volume.sh --inc"), "volume up", { locked = true, repeating = true })

bind("XF86AudioLowerVolume", exec(scriptsDir .. "/Volume.sh --dec"), "volume down", { locked = true, repeating = true })

bind(
	"ALT + XF86AudioRaiseVolume",
	exec(scriptsDir .. "/Volume.sh --inc-precise"),
	"volume up precise",
	{ locked = true, repeating = true }
)

bind(
	"ALT + XF86AudioLowerVolume",
	exec(scriptsDir .. "/Volume.sh --dec-precise"),
	"volume down precise",
	{ locked = true, repeating = true }
)

bind("XF86AudioMicMute", exec(scriptsDir .. "/Volume.sh --toggle-mic"), "toggle mic mute", { locked = true })

bind("XF86AudioMute", exec(scriptsDir .. "/Volume.sh --toggle"), "toggle mute", { locked = true })

bind("XF86Sleep", exec("systemctl suspend"), "sleep", { locked = true })

bind("XF86RFKill", exec(scriptsDir .. "/AirplaneMode.sh"), "airplane mode", { locked = true })

------------------------------------------------------------
-- Media controls
------------------------------------------------------------

-- XF86AudioPlayPause is not a real keysym (the play/pause key reports
-- XF86AudioPlay), so the .conf line for it never bound anything. Dropped.

bind("XF86AudioPause", exec(scriptsDir .. "/MediaCtrl.sh --pause"), "pause", { locked = true })

bind("XF86AudioPlay", exec(scriptsDir .. "/MediaCtrl.sh --pause"), "play", { locked = true })

bind("XF86AudioNext", exec(scriptsDir .. "/MediaCtrl.sh --nxt"), "next track", { locked = true })

bind("XF86AudioPrev", exec(scriptsDir .. "/MediaCtrl.sh --prv"), "previous track", { locked = true })

bind("XF86AudioStop", exec(scriptsDir .. "/MediaCtrl.sh --stop"), "stop", { locked = true })

------------------------------------------------------------
-- Screenshots
------------------------------------------------------------

bind(mainMod .. " + Print", exec(scriptsDir .. "/ScreenShot.sh --now"), "screenshot now")

bind(mainMod .. " + SHIFT + Print", exec(scriptsDir .. "/ScreenShot.sh --area"), "screenshot (area)")

bind(mainMod .. " + CTRL + Print", exec(scriptsDir .. "/ScreenShot.sh --in5"), "screenshot in 5s")

bind(mainMod .. " + CTRL + SHIFT + Print", exec(scriptsDir .. "/ScreenShot.sh --in10"), "screenshot in 10s")

bind("ALT + Print", exec(scriptsDir .. "/ScreenShot.sh --active"), "screenshot active window")

bind(mainMod .. " + SHIFT + S", exec(scriptsDir .. "/ScreenShot.sh --swappy"), "screenshot (swappy)")

------------------------------------------------------------
-- Resize windows
------------------------------------------------------------

local resizeBinds = {
	{ key = "left", x = -50, y = 0, description = "resize left (-50)" },
	{ key = "right", x = 50, y = 0, description = "resize right (+50)" },
	{ key = "up", x = 0, y = -50, description = "resize up (-50)" },
	{ key = "down", x = 0, y = 50, description = "resize down (+50)" },
}

for _, item in ipairs(resizeBinds) do
	bind(
		mainMod .. " + SHIFT + " .. item.key,
		hl.dsp.window.resize({ x = item.x, y = item.y, relative = true }),
		item.description,
		{ repeating = true }
	)
end

------------------------------------------------------------
-- Move / swap / focus windows
------------------------------------------------------------

local directions = {
	{ key = "left", short = "l", name = "left" },
	{ key = "right", short = "r", name = "right" },
	{ key = "up", short = "u", name = "up" },
	{ key = "down", short = "d", name = "down" },
}

for _, item in ipairs(directions) do
	bind(
		mainMod .. " + CTRL + " .. item.key,
		hl.dsp.window.move({ direction = item.short }),
		"move window " .. item.name
	)

	bind(
		mainMod .. " + ALT + " .. item.key,
		hl.dsp.window.swap({ direction = item.short }),
		"swap window " .. item.name
	)

	bind(mainMod .. " + " .. item.key, hl.dsp.focus({ direction = item.short }), "focus " .. item.name)
end

------------------------------------------------------------
-- Window groups
------------------------------------------------------------

bind(mainMod .. " + G", hl.dsp.group.toggle(), "toggle group")

bind(mainMod .. " + CTRL + Tab", hl.dsp.group.next(), "change active in group")

bind(mainMod .. " + CTRL + SHIFT + Tab", hl.dsp.group.prev(), "change active in group (back)")

bind(mainMod .. " + CTRL + K", hl.dsp.window.move({ into_group = "l" }), "Move left into group")

bind(mainMod .. " + CTRL + L", hl.dsp.window.move({ into_group = "r" }), "Move Right into group")

bind(mainMod .. " + CTRL + H", hl.dsp.window.move({ out_of_group = true }), "Move active out of group")

-- Experimental grouped-window navigation from the old config:
-- bind(mainMod .. " + right",
--     exec([[bash -c 'if hyprctl activewindow -j | jq -e "((.grouped | type) == \"boolean\") or (.address == (.grouped[-1] // empty))" >/dev/null 2>&1; then hyprctl dispatch movefocus r; else hyprctl dispatch changegroupactive f; fi']]),
--     "focus right"
-- )
--
-- bind(mainMod .. " + left",
--     exec([[bash -c 'if hyprctl activewindow -j | jq -e "((.grouped | type) == \"boolean\") or (.address == (.grouped[0] // empty))" >/dev/null 2>&1; then hyprctl dispatch movefocus l; else hyprctl dispatch changegroupactive b; fi']]),
--     "focus left"
-- )

------------------------------------------------------------
-- Workspaces
------------------------------------------------------------

bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "m+1" }), "next workspace")

bind(mainMod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "m-1" }), "previous workspace")

bind(
	mainMod .. " + SHIFT + U",
	hl.dsp.window.move({ workspace = "special", follow = true }),
	"move to special workspace"
)

bind(mainMod .. " + U", hl.dsp.workspace.toggle_special(), "toggle special workspace")

------------------------------------------------------------
-- Numbered workspaces, using keycodes
------------------------------------------------------------

for workspace = 1, 10 do
	local keycode = workspace + 9 -- workspace 1 -> code:10; workspace 10 -> code:19
	local key = "code:" .. keycode

	bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = workspace }), "workspace " .. workspace)

	bind(
		mainMod .. " + SHIFT + " .. key,
		hl.dsp.window.move({ workspace = workspace, follow = true }),
		"move to workspace " .. workspace
	)

	bind(
		mainMod .. " + CTRL + " .. key,
		hl.dsp.window.move({ workspace = workspace, follow = false }),
		"move silently to workspace " .. workspace
	)
end

bind(
	mainMod .. " + SHIFT + bracketleft",
	hl.dsp.window.move({ workspace = "-1", follow = true }),
	"move to previous workspace"
)

bind(
	mainMod .. " + SHIFT + bracketright",
	hl.dsp.window.move({ workspace = "+1", follow = true }),
	"move to next workspace"
)

bind(
	mainMod .. " + CTRL + bracketleft",
	hl.dsp.window.move({ workspace = "-1", follow = false }),
	"move silently to previous workspace"
)

bind(
	mainMod .. " + CTRL + bracketright",
	hl.dsp.window.move({ workspace = "+1", follow = false }),
	"move silently to next workspace"
)

------------------------------------------------------------
-- Snappy Switcher
------------------------------------------------------------

hl.bind("SUPER + grave", exec("snappy-switcher toggle"))
hl.bind("SUPER + SHIFT + grave", exec("snappy-switcher toggle --reverse"))

------------------------------------------------------------
-- Scroll / keyboard workspace navigation
------------------------------------------------------------

bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), "next workspace")

bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), "previous workspace")

bind(mainMod .. " + period", hl.dsp.focus({ workspace = "e+1" }), "next workspace")

bind(mainMod .. " + comma", hl.dsp.focus({ workspace = "e-1" }), "previous workspace")

------------------------------------------------------------
-- Mouse move / resize
------------------------------------------------------------

bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), "move window", { mouse = true })

bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), "resize window", { mouse = true })
