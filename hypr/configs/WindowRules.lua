-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
-- Vendor defaults for window rules and layer rules.
-- Hyprland >= 0.55 Lua configuration.
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/
---@diagnostic disable: undefined-global

local window_rule = hl.window_rule
local layer_rule = hl.layer_rule

------------------------------------------------------------
-- Optional workspace assignments
------------------------------------------------------------

-- window_rule({ match = { tag = "email*" },       workspace = "1" })
-- window_rule({ match = { tag = "browser*" },     workspace = "2" })
-- window_rule({ match = { tag = "projects*" },    workspace = "3" })
-- window_rule({ match = { tag = "screenshare*" }, workspace = "4 silent" })
-- window_rule({ match = { tag = "gamestore*" },   workspace = "5" })
-- window_rule({ match = { class = "^(virt-manager)$" }, workspace = "6 silent" })
-- window_rule({ match = { class = "^(.virt-manager-wrapped)$" }, workspace = "6 silent" })
-- window_rule({ match = { tag = "im*" },          workspace = "7" })
-- window_rule({ match = { class = "obsidian" },   workspace = "8" })
-- window_rule({ match = { tag = "games*" },       workspace = "8" })
-- window_rule({ match = { tag = "multimedia*" },  workspace = "9 silent" })

------------------------------------------------------------
-- Tags
------------------------------------------------------------

-- Browsers
window_rule({
	match = { class = "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr|[Ff]irefox-bin)$" },
	tag = "+browser",
})
window_rule({
	match = { class = "^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$" },
	tag = "+browser",
})
window_rule({
	match = { class = "^(chrome-.+-Default)$" },
	tag = "+browser",
})
window_rule({
	match = { class = "^([Cc]hromium)$" },
	tag = "+browser",
})
window_rule({
	match = { class = "^([Mm]icrosoft-edge(-stable|-beta|-dev|-unstable))$" },
	tag = "+browser",
})
window_rule({
	match = { class = "^(Brave-browser(-beta|-dev|-unstable)?)$" },
	tag = "+browser",
})
window_rule({
	match = { class = "^([Tt]horium-browser|[Cc]achy-browser)$" },
	tag = "+browser",
})
window_rule({
	match = { class = "^(zen-alpha|zen)$" },
	tag = "+browser",
})

-- Notifications
window_rule({
	match = { class = "^(swaync-control-center|swaync-notification-window|swaync-client|class)$" },
	tag = "+notif",
})

-- KooL settings
window_rule({
	match = { title = "^(KooL Quick Cheat Sheet)$" },
	tag = "+KooL_Cheat",
})
window_rule({
	match = { title = "^(KooL Hyprland Settings)$" },
	tag = "+KooL_Settings",
})
window_rule({
	match = { class = "^(nwg-displays|nwg-look)$" },
	tag = "+KooL-Settings",
})

-- Terminals
window_rule({
	match = { class = "^(Alacritty|kitty|kitty-dropterm)$" },
	tag = "+terminal",
})

-- Email
window_rule({
	match = { class = "^([Tt]hunderbird|org.mozilla.Thunderbird)$" },
	tag = "+email",
})
window_rule({
	match = { class = "^(eu.betterbird.Betterbird)$" },
	tag = "+email",
})
window_rule({
	match = { class = "^(org.gnome.Evolution)$" },
	tag = "+email",
})

-- Projects
window_rule({
	match = { class = "^(codium|codium-url-handler|VSCodium)$" },
	tag = "+projects",
})
window_rule({
	match = { class = "^(VSCode|code|code-url-handler|com.microsoft.VSCode)$" },
	tag = "+projects",
})
window_rule({
	match = { class = "^(jetbrains-.+)$" },
	tag = "+projects",
})
window_rule({
	match = { class = "^(dev.zed.Zed|antigravity)$" },
	tag = "+projects",
})

-- Screen sharing
window_rule({
	match = { class = "^(com.obsproject.Studio)$" },
	tag = "+screenshare",
})

-- Instant messaging
window_rule({
	match = { class = "^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$" },
	tag = "+im",
})
window_rule({
	match = { class = "^([Ff]erdium)$" },
	tag = "+im",
})
window_rule({
	match = { class = "^([Ww]hatsapp-for-linux)$" },
	tag = "+im",
})
window_rule({
	match = { class = "^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$" },
	tag = "+im",
})
window_rule({
	match = { class = "^(teams-for-linux)$" },
	tag = "+im",
})
window_rule({
	match = { class = "^(im.riot.Riot|Element)$" },
	tag = "+im",
})

-- Games
window_rule({
	match = { class = "^(gamescope)$" },
	tag = "+games",
})
window_rule({
	match = { class = "^(steam_app_\\d+)$" },
	tag = "+games",
})

-- Game stores
window_rule({
	match = { class = "^([Ss]team)$" },
	tag = "+gamestore",
})
window_rule({
	match = { title = "^([Ll]utris)$" },
	tag = "+gamestore",
})
window_rule({
	match = { class = "^(com.heroicgameslauncher.hgl)$" },
	tag = "+gamestore",
})

-- File managers
window_rule({
	match = { class = "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$" },
	tag = "+file-manager",
})
window_rule({
	match = { class = "^(app.drey.Warp)$" },
	tag = "+file-manager",
})

-- Wallpapers
window_rule({
	match = { class = "^([Ww]aytrogen)$" },
	tag = "+wallpaper",
})

-- Multimedia
window_rule({
	match = { class = "^([Aa]udacious)$" },
	tag = "+multimedia",
})
window_rule({
	match = { class = "^([Mm]pv|vlc)$" },
	tag = "+multimedia_video",
})

-- Settings
window_rule({
	match = { title = "^(ROG Control)$" },
	tag = "+settings",
})
window_rule({
	match = { class = "^(wihotspot(-gui)?)$" },
	tag = "+settings",
})
window_rule({
	match = { class = "^([Bb]aobab|org.gnome.[Bb]aobab)$" },
	tag = "+settings",
})
window_rule({
	match = { class = "^(gnome-disks|wihotspot(-gui)?)$" },
	tag = "+settings",
})
window_rule({
	match = { title = "(Kvantum Manager)" },
	tag = "+settings",
})
window_rule({
	match = { class = "^(file-roller|org.gnome.FileRoller)$" },
	tag = "+settings",
})
window_rule({
	match = { class = "^(nm-applet|nm-connection-editor|blueman-manager)$" },
	tag = "+settings",
})
window_rule({
	match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$" },
	tag = "+settings",
})
window_rule({
	match = { class = "^(qt5ct|qt6ct)$" },
	tag = "+settings",
})
window_rule({
	match = { class = "(xdg-desktop-portal-gtk)" },
	tag = "+settings",
})
window_rule({
	match = { class = "^(org.kde.polkit-kde-authentication-agent-1)$" },
	tag = "+settings",
})
window_rule({
	match = { class = "^([Rr]ofi)$" },
	tag = "+settings",
})
window_rule({
	match = { class = "^(btrfs-assistant)$" },
	tag = "+settings",
})
window_rule({
	match = { class = "^(timeshift-gtk)$" },
	tag = "+settings",
})

-- Viewers
window_rule({
	match = { class = "^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$" },
	tag = "+viewer",
})
window_rule({
	match = { class = "^(evince)$" },
	tag = "+viewer",
})
window_rule({
	match = { class = "^(eog|org.gnome.Loupe)$" },
	tag = "+viewer",
})

------------------------------------------------------------
-- Special overrides
------------------------------------------------------------

window_rule({
	match = { tag = "multimedia_video" },
	no_blur = true,
})
window_rule({
	match = { tag = "multimedia_video" },
	opacity = "1.0",
})
window_rule({
	match = { tag = "multimedia" },
	no_blur = true,
})
window_rule({
	match = { tag = "multimedia" },
	opacity = "1.0",
})

------------------------------------------------------------
-- Position
------------------------------------------------------------

window_rule({
	match = { tag = "KooL_Cheat" },
	center = true,
})
window_rule({
	match = { tag = "KooL-Settings" },
	center = true,
})
window_rule({
	match = { title = "^(ROG Control)$" },
	center = true,
})
window_rule({
	match = { title = "^(Keybindings)$" },
	center = true,
})
window_rule({
	match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$" },
	center = true,
})
window_rule({
	match = { class = "^([Ff]erdium)$" },
	center = true,
})

------------------------------------------------------------
-- Idle inhibition
------------------------------------------------------------

-- The first two rules intentionally preserve the duplicated source rules.
window_rule({
	match = { fullscreen = true },
	idle_inhibit = "fullscreen",
})
window_rule({
	match = { fullscreen = true },
	idle_inhibit = "fullscreen",
})

-- `^(*)$` is not valid RE2, so `.*` is used to preserve "match all".
window_rule({
	match = { class = ".*" },
	idle_inhibit = "fullscreen",
})
window_rule({
	match = { title = ".*" },
	idle_inhibit = "fullscreen",
})

------------------------------------------------------------
-- Floating windows
------------------------------------------------------------

window_rule({
	match = { tag = "KooL_Cheat" },
	float = true,
})
window_rule({
	match = { tag = "wallpaper" },
	float = true,
	center = true,
})
window_rule({
	match = { tag = "settings" },
	float = true,
	center = true,
})
window_rule({
	match = { tag = "viewer" },
	float = true,
	center = true,
})
window_rule({
	match = { tag = "KooL-Settings" },
	float = true,
	center = true,
})
window_rule({
	match = { class = "([Zz]oom|onedriver|onedriver-launcher)" },
	float = true,
})
window_rule({
	match = { class = "(org.gnome.Calculator|qalculate-gtk)" },
	float = true,
})
window_rule({
	match = { class = "^(mpv|com.github.rafostar.Clapper)$" },
	float = true,
})
window_rule({
	match = { class = "^([Qq]alculate-gtk)$" },
	float = true,
})
window_rule({
	match = { class = "^([Ff]erdium)$" },
	float = true,
})

------------------------------------------------------------
-- Popups and dialogs
------------------------------------------------------------

window_rule({
	match = { title = "^(Authentication Required)$" },
	float = true,
	center = true,
})
window_rule({
	match = {
		class = "(codium|codium-url-handler|VSCodium)",
		title = "negative:(.*codium.*|.*VSCodium.*)",
	},
	float = true,
})
window_rule({
	match = {
		class = "^(com.heroicgameslauncher.hgl)$",
		title = "negative:(Heroic Games Launcher)",
	},
	float = true,
})
window_rule({
	match = {
		class = "^([Ss]team)$",
		title = "negative:^([Ss]team)$",
	},
	float = true,
})
window_rule({
	match = { title = "^(Add Folder to Workspace)$" },
	float = true,
	size = { "monitor_w * 0.7", "monitor_h * 0.6" },
	center = true,
})
window_rule({
	match = { title = "^(Save As)$" },
	float = true,
	size = { "monitor_w * 0.7", "monitor_h * 0.6" },
	center = true,
})
window_rule({
	match = { initial_title = "(Open Files)" },
	float = true,
	size = { "monitor_w * 0.7", "monitor_h * 0.6" },
})
window_rule({
	match = { title = "^(SDDM Background)$" },
	float = true,
	center = true,
	size = { "monitor_w * 0.16", "monitor_h * 0.12" },
})
window_rule({
	match = { class = "^(yad)$" },
	float = true,
	center = true,
	size = { "monitor_w * 0.2", "monitor_h * 0.2" },
})
window_rule({
	match = { class = "^(hyprland-donate-screen)$" },
	float = true,
	center = true,
})

------------------------------------------------------------
-- Opacity
------------------------------------------------------------

window_rule({ match = { tag = "browser" }, opacity = "0.99 0.8" })
-- window_rule({ match = { tag = "projects" },     opacity = "0.9 0.8" })
window_rule({ match = { tag = "im" }, opacity = "0.94 0.86" })
window_rule({ match = { tag = "multimedia" }, opacity = "0.94 0.86" })
window_rule({ match = { tag = "file-manager" }, opacity = "0.9 0.8" })
window_rule({ match = { tag = "terminal" }, opacity = "0.9 0.7" })
window_rule({ match = { tag = "settings" }, opacity = "0.8 0.7" })
window_rule({ match = { tag = "viewer" }, opacity = "0.82 0.75" })
window_rule({ match = { tag = "wallpaper" }, opacity = "0.9 0.7" })

window_rule({
	match = { class = "^(gedit|org.gnome.TextEditor|mousepad)$" },
	opacity = "0.8 0.7",
})
window_rule({
	match = { class = "^(deluge)$" },
	opacity = "0.9 0.8",
})
window_rule({
	match = { class = "^(seahorse)$" },
	opacity = "0.9 0.8",
})
window_rule({
	match = { title = "^(Picture-in-Picture)$" },
	opacity = "0.95 0.75",
})

------------------------------------------------------------
-- Size
------------------------------------------------------------

window_rule({
	match = { tag = "KooL_Cheat" },
	size = { "monitor_w * 0.65", "monitor_h * 0.9" },
})
window_rule({
	match = { tag = "wallpaper" },
	size = { "monitor_w * 0.7", "monitor_h * 0.7" },
})
window_rule({
	match = { tag = "settings" },
	size = { "monitor_w * 0.7", "monitor_h * 0.7" },
})
window_rule({
	match = { class = "^([Ff]erdium)$" },
	size = { "monitor_w * 0.6", "monitor_h * 0.7" },
})

------------------------------------------------------------
-- Blur and fullscreen
------------------------------------------------------------

window_rule({
	match = { tag = "games" },
	no_blur = true,
	fullscreen = false,
})
window_rule({
	match = { tag = "games" },
	fullscreen = false,
})

------------------------------------------------------------
-- Focus overrides
------------------------------------------------------------

-- Corrected from `^(jetbrains-*)`, which does not mean "any suffix" in RE2.
window_rule({
	match = { class = "^(jetbrains-.*)$" },
	no_initial_focus = true,
})
window_rule({
	match = { title = "^(wind.*)$" },
	no_initial_focus = true,
})

------------------------------------------------------------
-- Layer rules
------------------------------------------------------------

layer_rule({
	match = { namespace = "rofi" },
	blur = true,
})
layer_rule({
	match = { namespace = "notifications" },
	blur = true,
})
layer_rule({
	match = { namespace = "quickshell:overview" },
	blur = true,
})
layer_rule({
	match = { namespace = "quickshell:overview" },
	ignore_alpha = 0.5,
})

------------------------------------------------------------
-- Named rules
------------------------------------------------------------

window_rule({
	name = "Whatsapp-zapzap",
	match = {
		class = "^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$",
	},
	size = { "monitor_w * 0.6", "monitor_h * 0.7" },
	center = true,
})

window_rule({
	name = "Picture-in-Picture",
	match = {
		title = "^(Picture-in-Picture)$",
	},
	float = true,
	move = { "72%", "7%" },
	opacity = "0.95 0.75",
	pin = true,
	keep_aspect_ratio = true,
	size = { "monitor_w * 0.3", "monitor_h * 0.3" },
})

window_rule({
	name = "Thunar-Progress-bar",
	match = {
		class = "^(thunar)$",
		title = "^(File Operation Progress)$",
	},
	float = true,
	center = true,
	size = { "monitor_w * 0.26", "monitor_h * 0.18" },
})
