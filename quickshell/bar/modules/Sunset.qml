import QtQuick
import "../components"
import "../services"

// hyprsunset night light
Btn {
    glyph: "bedtime"
    color: Theme.yellow
    struck: !Sys.sunset
    onClicked: Sys.toggleSunset()
}
