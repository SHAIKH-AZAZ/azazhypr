import QtQuick
import "../components"
import "../services"

// Idle inhibitor (the IdleInhibitor itself lives on the Bar window)
Btn {
    glyph: "\uf0f4"
    color: Theme.green
    struck: !Sys.inhibit
    onClicked: Sys.inhibit = !Sys.inhibit
}
