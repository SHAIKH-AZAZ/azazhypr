import QtQuick
import "../components"
import "../services"

// Pending pacman updates, hidden at 0. Panel has the "update" action.
Btn {
    property var bar
    visible: Config.showUpdates && Sys.updates > 0
    glyph: "upgrade"
    color: Theme.yellow
    label: Sys.updates
    onClicked: (item, b) => b === Qt.RightButton ? Sys.refreshSlow() : bar.toggle("system", item)
}
