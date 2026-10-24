#!/bin/sh
# Brings the window playing a track to the front.
# Usage: focus-player.sh <MPRIS bus name> <track title>
#
# The player's windows belong to the process that owns its MPRIS name. A
# browser names the playing tab in its window title only while that tab is
# the active one; otherwise the browser's tab search (Ctrl+Shift+A) is asked
# to switch to it. Keys are only sent while the player itself has focus.
name=$1 title=$2

pid=$(busctl --user call org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus \
    GetConnectionUnixProcessID s "$name" 2>/dev/null | awk '{print $2}')
[ -n "$pid" ] || exit 1

# The player's windows, most recently focused first.
windows() {
    hyprctl clients -j | jq -c --argjson pid "$pid" '[.[] | select(.pid == $pid)] | sort_by(.focusHistoryID)'
}
match() {
    windows | jq -r --arg t "$title" 'map(select(.title | contains($t))) | .[0].address // empty'
}
focus() {
    hyprctl dispatch "hl.dsp.focus({ window = \"address:$1\" })" >/dev/null
}
focused() {
    [ "$(hyprctl activewindow -j | jq -r '.pid')" = "$pid" ]
}

w=$(match)
if [ -n "$w" ]; then
    focus "$w"
    exit 0
fi

w=$(windows | jq -r '.[0].address // empty')
[ -n "$w" ] || exit 1
focus "$w"
case $(windows | jq -r '.[0].class') in
    *[Cc]hrom* | *[Bb]rave* | *[Vv]ivaldi* | *[Ee]dge*) ;;
    *) exit 0 ;;
esac

sleep 0.2
focused || exit 1
wtype -M ctrl -M shift -k a -m shift -m ctrl
sleep 0.4
focused || exit 1
wtype -- "$title"
sleep 0.3
focused || exit 1
wtype -k Return

# The tab may live in another window, which the browser raises without
# Hyprland following; focus it once its title names the track.
for _ in 1 2 3 4 5 6 7 8 9 10; do
    sleep 0.15
    w=$(match)
    if [ -n "$w" ]; then
        focus "$w"
        exit 0
    fi
done
# Nothing matched: close the search.
focused && wtype -k Escape
exit 1
