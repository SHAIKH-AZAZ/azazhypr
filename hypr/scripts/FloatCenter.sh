#!/usr/bin/env bash
# Float the focused window at 74% x 75% of its monitor, centered. Run again to tile it back.
w=$(hyprctl activewindow -j)
[ "$(jq -r '.floating // false' <<<"$w")" = true ] && { hyprctl dispatch 'hl.dsp.window.float({ action = "disable" })'; exit; }
# a maximized/fullscreen window refuses to resize: leave that state first
case "$(jq -r '.fullscreen // 0' <<<"$w")" in
  1) hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "maximized" })' ;;
  2) hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "fullscreen" })' ;;
esac
read -r W H < <(hyprctl monitors -j | jq -r '.[] | select(.focused) | "\((.width / .scale * 0.74) | floor) \((.height / .scale * 0.75) | floor)"')
hyprctl --batch "dispatch hl.dsp.window.float({ action = \"enable\" }) ; dispatch hl.dsp.window.resize({ x = $W, y = $H, relative = false }) ; dispatch hl.dsp.window.center()"
