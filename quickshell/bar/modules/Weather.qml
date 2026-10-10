import QtQuick
import "../components"
import "../services"

// wttr.in one-liner (location: Config.weatherLocation, "" = by IP). click: refresh
Btn {
    visible: Config.showWeather && Sys.weather !== ""
    color: Theme.fg
    label: Sys.weather
    onClicked: Sys.refreshSlow()
}
