import QtQuick
import QtQuick.Layouts
import "../services"

Item {
    id: s
    property real value
    property color color: Theme.accent
    signal moved(real v)
    Layout.fillWidth: true
    implicitHeight: 22
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width; height: 6; radius: 3
        color: Theme.subtle
        Rectangle { width: parent.width * Sys.clamp(s.value); height: parent.height; radius: 3; color: s.color }
    }
    MouseArea {
        anchors.fill: parent
        onPressed: m => s.moved(Sys.clamp(m.x / width))
        onPositionChanged: m => { if (pressed) s.moved(Sys.clamp(m.x / width)) }
    }
}
