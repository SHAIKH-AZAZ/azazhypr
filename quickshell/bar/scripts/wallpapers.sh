#!/bin/sh
# List image wallpapers (one path per line, sorted). Videos are left to WallpaperSelect.sh.
dir="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")/wallpapers"
find -L "$dir" -type f -not -path '*/.git/*' \
  \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \) | sort
