-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
-- Commands & apps to be executed at launch (vendor defaults).
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
---@diagnostic disable: undefined-global

-- /* ---- ✴️ Variables ✴️ */
local home = assert(os.getenv("HOME"), "HOME environment variable is not set")
local scriptsDir = home .. "/.config/hypr/scripts"
local userScripts = home .. "/.config/hypr/UserScripts"
local swwwRandom = userScripts .. "/WallpaperAutoChange.sh"
local wallDIR = home .. "/Pictures/wallpapers" -- change path manually here if needed

hl.on("hyprland.start", function()
	-- /* ---- 🖼️ Wallpaper stuff 🖼️ */
	hl.exec_cmd("awww-daemon --format xrgb")
	-- hl.exec_cmd([[mpvpaper '*' -o "load-scripts=no no-audio --loop" ]] .. livewallpaper)
	-- random wallpaper switcher every 30 minutes
	-- hl.exec_cmd(swwwRandom .. " " .. wallDIR)

	-- /* ---- 🚀 Startup 🚀 */
	-- hyprpm plugins are not auto-loaded at boot; without this the
	-- plugin:hyprdrive:* keys in plugins/hyprdrive.lua error out.
	hl.exec_cmd("hyprpm reload -n")
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd(scriptsDir .. "/Dropterminal.sh kitty &")
	hl.exec_cmd(scriptsDir .. "/Polkit.sh")
	-- nm-applet removed: the quickshell bar owns the wifi indicator
	-- hl.exec_cmd("nm-applet --indicator")
	-- hl.exec_cmd("nm-tray") -- For ubuntu
	-- swaync disabled: quickshell bar owns org.freedesktop.Notifications (only one owner allowed)
	-- hl.exec_cmd("swaync")
	-- hl.exec_cmd("ags")
	-- hl.exec_cmd("rog-control-center")
	hl.exec_cmd("qs -p /home/azaz/.config/quickshell/bar") -- quickshell bar + notifications + launcher
	hl.exec_cmd("qs -c overview") -- Quickshell Overview
	hl.exec_cmd("hypridle")
	hl.exec_cmd(scriptsDir .. "/Hyprsunset.sh init")

	-- /* ---- 📋 Clipboard manager 📋 */
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")

	-- /* ---- 🌈 Rainbow borders 🌈 */
	hl.exec_cmd(userScripts .. "/RainbowBorders.sh")

	-- /* ---- 💡 Available but disabled by default 💡 */
	-- Persistent wallpaper
	-- hl.exec_cmd("awww-daemon --format xrgb && awww img " .. wallDIR .. "/mecha-nostalgia.png")

	-- Gnome polkit for NixOS
	-- hl.exec_cmd(scriptsDir .. "/Polkit-NixOS.sh")

	-- xdg-desktop-portal-hyprland (should auto start, but you can force it)
	-- hl.exec_cmd(scriptsDir .. "/PortalHyprland.sh")

	-- blueman-applet removed: the quickshell bar owns the bt indicator
	-- hl.exec_cmd("blueman-applet")
	hl.exec_cmd("qs -c overview") -- Quickshell Overview
end)

-- ponytail: only referenced by the commented-out wallpaper lines above.
local _ = { swwwRandom, wallDIR }
