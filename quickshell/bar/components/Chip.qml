import QtQuick
import QtQuick.Layouts
import "../services"

Rectangle {
    id: chip
    property string glyph
    property string text
    property bool on: false
    signal clicked
    Layout.fillWidth: true
    implicitHeight: 52
    radius: 10
    color: on ? Theme.accent : Theme.subtle
    opacity: ma.containsMouse ? 0.85 : 1
    Column {
        anchors.centerIn: parent
        spacing: 2
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: chip.glyph; color: chip.on ? Theme.bg : Theme.fg; font { family: Theme.font; pixelSize: 18 } }
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: chip.text; color: chip.on ? Theme.bg : Theme.fg; font { family: Theme.font; pixelSize: 11 } }
    }
    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: chip.clicked() }
}
