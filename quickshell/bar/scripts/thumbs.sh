#!/bin/sh
# Build small JPEG thumbnails of every wallpaper: $1/<md5 of the path>.jpg (Qt.md5 of the same string).
# Idempotent and niced: the first run takes a while in the background, later runs only check files.
out="$1"
export MAGICK_THREAD_LIMIT=1
mkdir -p "$out"
sh "$(dirname "$0")/wallpapers.sh" | while IFS= read -r f; do
    h=$(printf %s "$f" | md5sum | cut -d' ' -f1)
    [ -s "$out/$h.jpg" ] && continue
    nice -n 19 magick "$f[0]" -auto-orient -thumbnail 480x290^ -gravity center -extent 480x290 -quality 80 "$out/$h.jpg" 2>/dev/null \
        || ln -sf "$f" "$out/$h.jpg"
done
