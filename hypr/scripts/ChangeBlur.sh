#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script for changing blurs on the fly

notif="$HOME/.config/swaync/images"

STATE=$(hyprctl -j getoption decoration:blur:passes | jq ".int")

if [ "${STATE}" -gt 1 ]; then
	# ponytail: `hyprctl keyword` is a no-op under the Lua configProvider, must use eval
	hyprctl eval 'hl.config({ decoration = { blur = { size = 2, passes = 1 } } })'
 	notify-send -e -u low -i "$notif/note.png" " Less Blur"
else
	# reload restores whatever UserDecorations.lua sets, no hardcoded values to drift
	hyprctl reload
  	notify-send -e -u low -i "$notif/ja.png" " Normal Blur"
fi
