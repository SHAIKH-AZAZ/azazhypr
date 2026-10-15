import QtQuick
import "../components"
import "../services"

// Idle inhibitor (the IdleInhibitor itself lives on the Bar window)
Btn {
    glyph: "coffee"
    color: Theme.green
    struck: !Sys.inhibit
    onClicked: Sys.inhibit = !Sys.inhibit
}
