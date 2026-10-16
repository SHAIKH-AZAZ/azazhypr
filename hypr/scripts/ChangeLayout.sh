#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# for changing Hyprland Layouts (Master or Dwindle) on the fly
#
# NOTE: under the lua config parser `hyprctl keyword` is rejected
# ("keyword can't work with non-legacy parsers"), so the layout is set through
# `hyprctl eval` instead. Layout-specific keybinds are no longer rebound here --
# configs/Keybinds.lua picks the right dispatcher at press time.

notif="$HOME/.config/swaync/images/ja.png"

LAYOUT=$(hyprctl -j getoption general:layout | jq -r '.str')

# Reverse layout value to reuse toggle logic. So layouts don't get swapped initially.
if [ "$1" = "init" ]; then
  if [ "$LAYOUT" = "master" ]; then
    LAYOUT="dwindle"
  else
    LAYOUT="master"
  fi
fi

set_layout() {
  hyprctl eval "hl.config({ general = { layout = '$1' } })" >/dev/null
}

case $LAYOUT in
"master")
  set_layout dwindle
  notify-send -e -u low -i "$notif" " Dwindle Layout"
  ;;
"dwindle")
  set_layout master
  notify-send -e -u low -i "$notif" " Master Layout"
  ;;
*) ;;

esac
