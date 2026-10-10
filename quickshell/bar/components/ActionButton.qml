import QtQuick
import "../services"

// Notification action button: tinted ghost style, red for destructive actions.
Rectangle {
    id: root
    property string text
    readonly property bool danger: /delete|dismiss|remove|discard|cancel|reject/i.test(text)
    readonly property color tint: danger ? Theme.red : Theme.accent
    signal clicked

    implicitWidth: label.implicitWidth + 24
    implicitHeight: 28
    radius: 8
    color: Qt.alpha(tint, ma.containsMouse ? 0.30 : 0.14)
    border { width: 1; color: Qt.alpha(tint, ma.containsMouse ? 0.9 : 0.45) }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.tint
        font { family: Theme.font; pixelSize: 11; bold: true }
    }
    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: root.clicked() }
}
