import QtQuick
import "../components"
import "../services"

// Temperature in the bar. Click: weather panel. The label is the wttr.in one-liner
// (location: Config.weatherLocation, "" = by IP); before that arrives it falls back to the panel data.
Btn {
    property var bar
    readonly property string fallback: Forecast.cur
        ? Forecast.icon(Forecast.cur.weather_code, Forecast.cur.is_day === 1) + " " + Math.round(Forecast.cur.temperature_2m) + "°C" : ""
    visible: Config.showWeather && (Sys.weather !== "" || fallback !== "")
    // wttr.in starts with an emoji ("☀️ +34°C"): swap it for a Material icon, keep the temperature
    readonly property string raw: Sys.weather !== "" ? Sys.weather : fallback
    readonly property string emoji: raw.split(" ")[0]
    glyph: /☀|🌞/.test(emoji) ? "sunny" : /🌙/.test(emoji) ? "bedtime" : /⛅|🌤|🌥/.test(emoji) ? "partly_cloudy_day"
         : /⛈|🌩/.test(emoji) ? "thunderstorm" : /🌧|🌦/.test(emoji) ? "rainy" : /🌨|❄/.test(emoji) ? "weather_snowy"
         : /🌫/.test(emoji) ? "foggy" : /☁/.test(emoji) ? "cloud" : /✨/.test(emoji) ? "clear_day" : "device_thermostat"
    color: Theme.fg
    label: raw.replace(/^\S+\s+/, "")
    onClicked: item => bar.toggle("weather", item)
}
