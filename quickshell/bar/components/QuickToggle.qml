import QtQuick
import QtQuick.Layouts
import "../services"

// Dashboard tile: rounded square glyph + label, accent when on.
Item {
    id: root
    property string glyph
    property string text
    property bool on: false
    signal clicked

    Layout.fillWidth: true
    implicitHeight: 70

    Column {
        anchors.centerIn: parent
        spacing: 6
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 40; height: 40; radius: 12
            color: root.on ? Theme.accent : Theme.subtle
            opacity: ma.containsMouse ? 0.85 : 1
            Text {
                anchors.centerIn: parent
                text: root.glyph
                color: root.on ? Theme.bg : Theme.fg
                font { family: Theme.iconFont; pixelSize: 21 }
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.text
            color: root.on ? Theme.fg : Theme.muted
            font { family: Theme.font; pixelSize: 11 }
        }
    }
    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: root.clicked() }
}
