#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script for Monitor backlights (if supported) using brightnessctl

step=10  # INCREASE/DECREASE BY THIS VALUE

# Get current brightness as an integer (without %)
get_brightness() {
    brightnessctl -m | cut -d, -f4 | tr -d '%'
}

# Change brightness
change_brightness() {
    local delta=$1
    local current new

    current=$(get_brightness)
    new=$((current + delta))

    # Clamp between 5 and 100
    (( new < 5 )) && new=5
    (( new > 100 )) && new=100

    # The quickshell island's HUD shows the level.
    brightnessctl set "${new}%"
}

# Main
case "$1" in
    "--get")
        get_brightness
        ;;
    "--inc")
        change_brightness "$step"
        ;;
    "--dec")
        change_brightness "-$step"
        ;;
    *)
        get_brightness
        ;;
esac