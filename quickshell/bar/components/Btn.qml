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
    property color struckColor: color       // colour of the strike-through line (e.g. red on a muted speaker)
    property bool pulse: false              // slow breathing: charging, connected
    property bool blink: false              // fast blink: low battery
    property var pop: undefined             // changes -> the icon bounces once (mute toggled, device connected)

    onPopChanged: if (pop !== undefined) popAnim.restart()

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
            Behavior on color { ColorAnimation { duration: 200 } }

            // breathing / blinking
            SequentialAnimation on opacity {
                running: root.pulse || root.blink
                loops: Animation.Infinite
                onRunningChanged: if (!running) iconText.opacity = 1
                NumberAnimation { to: root.blink ? 0.2 : 0.5; duration: root.blink ? 450 : 900; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1; duration: root.blink ? 450 : 900; easing.type: Easing.InOutSine }
            }
            // one bounce when `pop` changes
            SequentialAnimation {
                id: popAnim
                NumberAnimation { target: iconText; property: "scale"; to: 0.6; duration: 90; easing.type: Easing.OutQuad }
                NumberAnimation { target: iconText; property: "scale"; to: 1.25; duration: 140; easing.type: Easing.OutBack }
                NumberAnimation { target: iconText; property: "scale"; to: 1; duration: 120 }
            }
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
        color: root.struckColor
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
