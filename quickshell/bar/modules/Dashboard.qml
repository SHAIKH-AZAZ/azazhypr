import QtQuick
import "../components"
import "../services"

// Arch button -> session menu
Btn {
    property var bar
    glyph: "\uf303"; size: 22
    color: Theme.accent
    onClicked: item => bar.toggle("dashboard", item)
}
