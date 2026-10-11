#!/bin/sh
# Weather bundle for the weather panel, as one JSON object on stdout.
#   $1 = location: "" (guess from IP), a city name, or "lat,lon"
#   $2 = display name to show for a "lat,lon" location (picked from the suggestions)
# wttr.in resolves the place (and IP guess); Open-Meteo supplies forecast + air quality.
loc="$1"
case "$loc" in
    *[0-9].[0-9]*,*[0-9]*) lat="${loc%%,*}"; lon="${loc##*,}"; place="${2:-$loc}" ;;
    *)
        a=$(curl -fsS --max-time 8 "wttr.in/$(printf %s "$loc" | sed 's/ /+/g')?format=j1") || exit 1
        lat=$(printf %s "$a" | jq -r '.nearest_area[0].latitude')
        lon=$(printf %s "$a" | jq -r '.nearest_area[0].longitude')
        place=$(printf %s "$a" | jq -r '.nearest_area[0] | "\(.areaName[0].value), \(.country[0].value)"')
        ;;
esac
[ -n "$lat" ] && [ "$lat" != null ] || exit 1
f=$(curl -fsS --max-time 10 "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,apparent_temperature,relative_humidity_2m,pressure_msl,wind_speed_10m,wind_direction_10m,weather_code,visibility,is_day&hourly=temperature_2m,weather_code,is_day&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset&timezone=auto&forecast_days=7&wind_speed_unit=kmh") || exit 1
q=$(curl -fsS --max-time 8 "https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$lat&longitude=$lon&current=us_aqi" 2>/dev/null || echo '{}')
jq -n --arg place "$place" --argjson f "$f" --argjson q "${q:-{\}}" '{place: $place, f: $f, aqi: ($q.current.us_aqi // null)}'
