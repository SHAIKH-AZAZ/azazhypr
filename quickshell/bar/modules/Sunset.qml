import QtQuick
import "../components"
import "../services"

// hyprsunset night light
Btn {
    glyph: "\uf186"
    color: Theme.yellow
    struck: !Sys.sunset
    onClicked: Sys.toggleSunset()
}
