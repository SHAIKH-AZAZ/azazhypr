#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# For applying Animations from different users

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

# Variables
iDIR="$HOME/.config/swaync/images"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
animations_dir="$HOME/.config/hypr/animations"
UserConfigs="$HOME/.config/hypr/UserConfigs"
rofi_theme="$HOME/.config/rofi/config-Animations.rasi"
msg='❗NOTE:❗ This will overwrite UserAnimations.lua'
# list of animation files, sorted alphabetically with numbers first
animations_list=$(find -L "$animations_dir" -maxdepth 1 -type f | sed 's/.*\///' | sed 's/\.conf$//' | sort -V)

# Rofi Menu
chosen_file=$(echo "$animations_list" | rofi -i -dmenu -config $rofi_theme -mesg "$msg")

# Check if a file was selected
if [[ -n "$chosen_file" ]]; then
    full_path="$animations_dir/$chosen_file.conf"
    target="$UserConfigs/UserAnimations.lua"
    # Hyprland runs the Lua config provider, which never reads .conf, so the
    # preset has to be translated. Written via a temp file so a failed
    # conversion cannot leave a half-written config behind.
    if awk -v preset="$chosen_file" -f "$SCRIPTSDIR/AnimConfToLua.awk" "$full_path" > "$target.tmp"; then
        [ -f "$target" ] && cp "$target" "$target.bak"
        mv "$target.tmp" "$target"
        notify-send -u low -i "$iDIR/ja.png" "$chosen_file" "Hyprland Animation Loaded"
    else
        rm -f "$target.tmp"
        notify-send -u critical -i "$iDIR/ja.png" "$chosen_file" "Failed to convert animation preset"
    fi
fi

sleep 1
"$SCRIPTSDIR/RefreshNoWaybar.sh"
