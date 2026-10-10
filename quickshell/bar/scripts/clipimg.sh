#!/bin/sh
# Decode the newest image entries of the cliphist history to $1/<id>.png (launcher previews).
d="$1"
mkdir -p "$d"
find "$d" -name '*.png' -mtime +1 -delete 2>/dev/null
cliphist list | awk -F'\t' '/^[0-9]+\t\[\[ binary data/ {print $1}' | head -30 | while read -r id; do
    [ -s "$d/$id.png" ] || cliphist decode "$id" > "$d/$id.png" 2>/dev/null
done
