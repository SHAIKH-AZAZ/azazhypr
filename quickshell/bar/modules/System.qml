import QtQuick
import "../components"
import "../services"

// CPU % -> system panel
Btn {
    property var bar
    visible: Config.showSystem
    glyph: ""
    color: Theme.blue
    label: Math.round(Sys.cpu) + "%"
    onClicked: item => bar.toggle("system", item)
}
