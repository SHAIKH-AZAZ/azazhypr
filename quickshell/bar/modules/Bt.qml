import QtQuick
import Quickshell.Bluetooth
import "../components"
import "../services"

Btn {
    property var bar
    glyph: "\uf293"
    color: Theme.blue
    struck: !(Bluetooth.defaultAdapter?.enabled ?? false)
    onClicked: item => bar.toggle("bluetooth", item)
}
