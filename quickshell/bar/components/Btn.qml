import QtQuick
import "../services"

// Bar button: icon glyph + optional label; hover bg; click/scroll signals.
Item {
    id: root

    property string glyph
    property string label
    property color color: Theme.fg
    property color labelColor: color
    property int size: 18
    property bool spin: false
    property bool badge: false
    property bool struck: false

    signal clicked(var item, int button)
    signal scrolled(int dir)

    implicitWidth: row.implicitWidth + 14
    implicitHeight: 28

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Theme.fg
        opacity: mouse.containsMouse ? 0.1 : 0
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5

        Text {
            id: iconText
            visible: text !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: root.glyph
            color: root.color
            font { family: Theme.font; pixelSize: root.size }
            NumberAnimation on rotation {
                from: 0; to: 360; duration: 3000
                loops: Animation.Infinite
                running: root.spin
            }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: text !== ""
            text: root.label
            color: root.labelColor
            font { family: Theme.font; pixelSize: 12 }
        }
    }

    Rectangle {
        visible: root.struck
        anchors.centerIn: row
        width: root.size * 1.15; height: 2; radius: 1
        rotation: -45
        color: root.color
    }

    Rectangle {
        visible: root.badge
        width: 7; height: 7; radius: 4
        color: Theme.accent
        anchors { right: parent.right; top: parent.top; rightMargin: 4; topMargin: 3 }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: m => root.clicked(root, m.button)
        onWheel: w => root.scrolled(w.angleDelta.y > 0 ? 1 : -1)
    }
}
