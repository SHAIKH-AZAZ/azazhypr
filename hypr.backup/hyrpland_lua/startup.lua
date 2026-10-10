local config = require("config")
local h = require("lib")

local p = config.paths

return {
  h.var("$scriptsDir", p.scripts),
  h.var("$UserScripts", p.user_scripts),
  h.var("$lock", "$scriptsDir/LockScreen.sh"),
  h.var("$SwwwRandom", "$UserScripts/WallpaperAutoChange.sh"),
  h.var("$livewallpaper", '""'),
  h.var("$wallDIR", "$HOME/Pictures/wallpapers"),

  h.blank(),
  h.comment("Wallpaper daemon"),
  h.exec_once("awww-daemon --format xrgb"),

  h.blank(),
  h.comment("Session startup"),
  h.exec_once("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"),
  h.exec_once("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"),
  h.exec_once("$HOME/.config/hypr/scripts/Dropterminal.sh kitty &"),
  h.exec_once("$scriptsDir/Polkit.sh"),
  h.exec_once("nm-applet --indicator"),
  h.exec_once("nm-tray"),
  h.exec_once("swaync"),
  h.exec_once("waybar"),
  h.exec_once("qs -c overview"),
  h.exec_once("hypridle"),
  h.exec_once("$scriptsDir/Hyprsunset.sh init"),

  h.blank(),
  h.comment("Clipboard manager"),
  h.exec_once("wl-paste --type text --watch cliphist store"),
  h.exec_once("wl-paste --type image --watch cliphist store"),

  h.blank(),
  h.exec_once("blueman-applet"),
  h.exec_once("$scriptsDir/KeybindsLayoutInit.sh"),
}
