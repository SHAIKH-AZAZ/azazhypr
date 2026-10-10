#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# source https://wiki.archlinux.org/title/Hyprland#Using_a_script_to_change_wallpaper_every_X_minutes

# This script will randomly go through the files of a directory, setting it
# up as the wallpaper at regular intervals
#
# NOTE: this script uses bash (not POSIX shell) for the RANDOM variable

wallust_refresh=$HOME/.config/hypr/scripts/RefreshNoWaybar.sh

focused_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')

if [[ $# -lt 1 ]] || [[ ! -d "$1" ]]; then
	echo "Usage:
	$0 <dir containing images>"
	exit 1
fi

# Edit below to control the images transition
export AWWW_TRANSITION_FPS=60
export AWWW_TRANSITION=simple

# This controls (in seconds) when to switch to the next image
INTERVAL=1800

if ! awww query >/dev/null 2>&1; then
	awww-daemon --format xrgb &
	sleep 0.2
fi

while true; do
	find "$1" \
		-type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.pnm" -o -iname "*.tga" -o -iname "*.tiff" -o -iname "*.webp" -o -iname "*.bmp" -o -iname "*.farbfeld" -o -iname "*.gif" \) \
		-print0 \
		| shuf -z \
		| while IFS= read -r -d '' img; do
			awww img -o "$focused_monitor" "$img"
			# Regenerate colors from the exact image path to avoid cache races
				$HOME/.config/hypr/scripts/WallustSwww.sh "$img"
				# Refresh UI components that depend on wallust output
				"$wallust_refresh"
				sleep "$INTERVAL"
			
		done
done
