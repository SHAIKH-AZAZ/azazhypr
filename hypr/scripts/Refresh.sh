#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Scripts for refreshing rofi, wallust

SCRIPTSDIR=$HOME/.config/hypr/scripts
UserScripts=$HOME/.config/hypr/UserScripts

file_exists() { [ -e "$1" ]; }

# Kill already running rofi
if pidof rofi >/dev/null; then
  pkill rofi
fi

# quit ags & relaunch ags
#ags -q && ags &

# quickshell bar: no restart needed, it watches ~/.config/quickshell/qml_color.json
# (wallust rewrites it) and live-reloads. Do not pkill qs here, that kills the bar.

# nudge rofi/swaybg to reload their theme
for pid in $(pidof rofi swaybg); do
  kill -SIGUSR1 "$pid"
done

# Relaunching rainbow borders if the script exists (reads wallust's output file,
# which callers already write before invoking this script)
if file_exists "${UserScripts}/RainbowBorders.sh"; then
  ${UserScripts}/RainbowBorders.sh &
fi

exit 0
