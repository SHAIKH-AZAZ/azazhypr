import QtQuick
import "../theme"

// A Wi-Fi fan lit up to the signal strength (0..100): the dot, then the
// middle arc, then the outer one. Unlit parts stay faint.
Item {
    id: root

    property int signal: 0
    property real size: 15
    property color color: Theme.text
    readonly property int bars: signal >= 70 ? 3 : signal >= 40 ? 2 : 1

    implicitWidth: size
    implicitHeight: size

    Repeater {
        model: ["wifiDot", "wifiMiddle", "wifiOuter"]

        Icon {
            required property string modelData
            required property int index

            anchors.centerIn: parent
            name: modelData
            size: root.size
            color: root.color
            opacity: index < root.bars ? 1 : 0.25
            Behavior on opacity { NumberAnimation { duration: Theme.fadeDuration } }
        }
    }
}
