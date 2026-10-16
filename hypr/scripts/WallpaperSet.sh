#!/usr/bin/env bash
# WallpaperSet.sh <image> [monitor] [awww args...]
# Change wallpaper through the quickshell dissolve when the bar runs; else plain awww with its transition.
img="$1"; mon="$2"; shift 2 2>/dev/null
BAR="$HOME/.config/quickshell/bar"
if pgrep -x qs >/dev/null && qs -p "$BAR" ipc call wallpaper set "$img" >/dev/null 2>&1; then
  exit 0
fi
if [[ -n "$mon" ]]; then awww img -o "$mon" "$img" "$@"; else awww img "$img" "$@"; fi
