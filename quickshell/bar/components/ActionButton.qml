import QtQuick
import "../services"

// Notification action button. Three looks, all with readable text on the black card:
//   primary   (first action)  solid accent, dark text
//   secondary                 grey fill, light text
//   danger    (delete, ...)   red tint + red text, solid red on hover
Rectangle {
    id: root
    property string text
    property bool primary: false
    readonly property bool danger: /delete|dismiss|remove|discard|cancel|reject/i.test(text)
    readonly property bool hot: ma.containsMouse
    signal clicked

    implicitWidth: label.implicitWidth + 28
    implicitHeight: 30
    radius: Config.notifRadius
    color: danger ? (hot ? Theme.red : Qt.alpha(Theme.red, 0.16))
        : primary ? (hot ? Qt.lighter(Theme.accent, 1.2) : Theme.accent)
        : Qt.alpha(Theme.fg, hot ? 0.20 : 0.10)
    border {
        width: primary && !danger ? 0 : 1
        color: danger ? Qt.alpha(Theme.red, hot ? 1 : 0.6) : Qt.alpha(Theme.fg, 0.25)
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.danger ? (root.hot ? Theme.bg : Theme.red)
            : root.primary ? Theme.bg
            : Theme.fg
        font { family: Theme.font; pixelSize: 12; bold: true }
    }
    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: root.clicked() }
}
