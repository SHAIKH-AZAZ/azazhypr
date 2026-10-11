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
    color: Theme.fg
    label: Sys.weather !== "" ? Sys.weather : fallback
    onClicked: item => bar.toggle("weather", item)
}
