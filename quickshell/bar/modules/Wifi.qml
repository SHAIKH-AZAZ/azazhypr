import QtQuick
import "../components"
import "../services"

Btn {
    property var bar
    glyph: Sys.wifi ? "wifi" : "wifi_off"
    color: Sys.wifi ? Theme.fg : Theme.muted
    onClicked: item => bar.toggle("network", item)
}
