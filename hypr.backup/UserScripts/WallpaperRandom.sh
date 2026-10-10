#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script for Random Wallpaper ( CTRL ALT W)

PICTURES_DIR="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")"
wallDIR="$PICTURES_DIR/wallpapers"
SCRIPTSDIR="$HOME/.config/hypr/scripts"

focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

mapfile -d '' PICS < <(find -L "${wallDIR}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.pnm" -o -iname "*.tga" -o -iname "*.tiff" -o -iname "*.webp" -o -iname "*.bmp" -o -iname "*.farbfeld" -o -iname "*.gif" \) -print0)

if (( ${#PICS[@]} == 0 )); then
  notify-send "Wallpaper" "No images found in $wallDIR"
  exit 1
fi

RANDOMPICS="${PICS[$((RANDOM % ${#PICS[@]}))]}"


# Transition config
FPS=30
TYPE="random"
DURATION=1
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS=(--transition-fps "$FPS" --transition-type "$TYPE" --transition-duration "$DURATION" --transition-bezier "$BEZIER")

if ! awww query >/dev/null 2>&1; then
  awww-daemon --format xrgb &
  sleep 0.2
fi

awww img -o "$focused_monitor" "$RANDOMPICS" "${SWWW_PARAMS[@]}"
"$SCRIPTSDIR/WallustSwww.sh" "$RANDOMPICS"

sleep 2
"$SCRIPTSDIR/Refresh.sh"
