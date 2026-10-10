import QtQuick
import "../components"
import "../services"

Btn {
    property var bar
    glyph: "\uf1eb"
    color: Sys.wifi ? Theme.accent : Theme.muted
    onClicked: item => bar.toggle("network", item)
}
