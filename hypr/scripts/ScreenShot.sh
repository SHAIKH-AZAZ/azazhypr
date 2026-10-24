#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Screenshots scripts

# variables
time=$(date "+%d-%b_%H-%M-%S")
PICTURES_DIR="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")"
dir="$PICTURES_DIR/Screenshots"
file="Screenshot_${time}_${RANDOM}.png"

iDIR="$HOME/.config/swaync/icons"
iDoR="$HOME/.config/swaync/images"
sDIR="$HOME/.config/hypr/scripts"

active_window_class=$(hyprctl -j activewindow | jq -r '(.class)')
active_window_file="Screenshot_${time}_${active_window_class}.png"
active_window_path="${dir}/${active_window_file}"

# Notifications name the app, carry the shot as a preview (x-latto-preview puts
# it beside the text on the island) and open it on click.
shot_icon=/usr/share/icons/Papirus/48x48/apps/org.gnome.Screenshot.svg
[[ -f "$shot_icon" ]] || shot_icon="${iDIR}/picture.png"

# $1 summary, $2 body, $3 image; prints the action picked (default or delete).
notify_shot() {
	notify-send -a "Screenshot" -n "$shot_icon" -t 10000 \
		-h string:x-canonical-private-synchronous:shot-notify \
		-h "string:image-path:$3" -h boolean:x-latto-preview:true \
		-A default=Open -A delete=Delete "$1" "$2"
}

notify_failed() {
	notify-send -a "Screenshot" -u low -n "$shot_icon" "Screenshot failed" "Nothing was saved"
	"${sDIR}/Sounds.sh" --error
}

# notify and view screenshot
notify_view() {
	if [[ "$1" == "active" ]]; then
		if [[ -e "${active_window_path}" ]]; then
			"${sDIR}/Sounds.sh" --screenshot &
			case "$(notify_shot "Window captured" "${active_window_class} · saved to Screenshots" "${active_window_path}")" in
				default) xdg-open "${active_window_path}" & ;;
				delete) rm "${active_window_path}" & ;;
			esac
		else
			notify_failed
		fi

	elif [[ "$1" == "swappy" ]]; then
		"${sDIR}/Sounds.sh" --screenshot &
		case "$(notify_shot "Screenshot copied" "Click to edit in Swappy" "$tmpfile")" in
			default) swappy -f - <"$tmpfile" ;;
			delete) rm "$tmpfile" ;;
		esac

	else
		local check_file="${dir}/${file}"
		if [[ -e "$check_file" ]]; then
			"${sDIR}/Sounds.sh" --screenshot &
			case "$(notify_shot "Screenshot saved" "Copied to clipboard · saved to Screenshots" "$check_file")" in
				default) xdg-open "${check_file}" & ;;
				delete) rm "${check_file}" & ;;
			esac
		else
			notify_failed
		fi
	fi
}

# countdown
countdown() {
	for sec in $(seq $1 -1 1); do
		notify-send -a "Screenshot" -n "$shot_icon" -t 1000 -h string:x-canonical-private-synchronous:shot-notify "Taking a screenshot" "in ${sec}s"
		sleep 1
	done
}

# take shots
shotnow() {
	# -l 1: fast PNG compression (default 6 is the slow part); no sleep, the pipe has finished
	cd ${dir} && grim -l 1 - | tee "$file" | wl-copy
	notify_view
}

shot5() {
	countdown '5'
	sleep 1 && cd ${dir} && grim - | tee "$file" | wl-copy
	sleep 1
	notify_view
}

shot10() {
	countdown '10'
	sleep 1 && cd ${dir} && grim - | tee "$file" | wl-copy
	notify_view
}

shotwin() {
	w_pos=$(hyprctl activewindow | grep 'at:' | cut -d':' -f2 | tr -d ' ' | tail -n1)
	w_size=$(hyprctl activewindow | grep 'size:' | cut -d':' -f2 | tr -d ' ' | tail -n1 | sed s/,/x/g)
	cd ${dir} && grim -g "$w_pos $w_size" - | tee "$file" | wl-copy
	notify_view
}

shotarea() {
	tmpfile=$(mktemp)
	grim -l 1 -g "$(slurp)" - >"$tmpfile"

  # Copy with saving
	if [[ -s "$tmpfile" ]]; then
		wl-copy <"$tmpfile"
		mv "$tmpfile" "$dir/$file"
	fi
	notify_view
}

shotactive() {
    active_window_class=$(hyprctl -j activewindow | jq -r '(.class)')
    active_window_file="Screenshot_${time}_${active_window_class}.png"
    active_window_path="${dir}/${active_window_file}"

    hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | grim -l 1 -g - "${active_window_path}"
    notify_view "active"
}

shotswappy() {
	tmpfile=$(mktemp)
	grim -l 1 -g "$(slurp)" - >"$tmpfile" 

  # Copy without saving
  if [[ -s "$tmpfile" ]]; then
		wl-copy <"$tmpfile"
    notify_view "swappy"
  fi
}

if [[ ! -d "$dir" ]]; then
	mkdir -p "$dir"
fi

if [[ "$1" == "--now" ]]; then
	shotnow
elif [[ "$1" == "--in5" ]]; then
	shot5
elif [[ "$1" == "--in10" ]]; then
	shot10
elif [[ "$1" == "--win" ]]; then
	shotwin
elif [[ "$1" == "--area" ]]; then
	shotarea
elif [[ "$1" == "--active" ]]; then
	shotactive
elif [[ "$1" == "--swappy" ]]; then
	shotswappy
else
	echo -e "Available Options : --now --in5 --in10 --win --area --active --swappy"
fi

exit 0
