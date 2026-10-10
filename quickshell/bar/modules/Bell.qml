import QtQuick
import "../components"
import "../services"

// Notifications. click: list, right-click: do-not-disturb
Btn {
    property var bar
    glyph: Notifs.dnd ? "\uf1f6" : "\uf0f3"
    color: Theme.blue
    badge: Notifs.list.values.length > 0 && !Notifs.dnd
    onClicked: (item, b) => b === Qt.RightButton ? Notifs.dnd = !Notifs.dnd : bar.toggle("notifications", item)
}
