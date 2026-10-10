import QtQuick
import "../components"
import "../services"

// Down/up speed
Text {
    anchors.verticalCenter: parent.verticalCenter
    leftPadding: 6; rightPadding: 6
    color: Theme.blue
    font { family: Theme.font; pixelSize: 12 }
    text: "\u2193" + Sys.fmt(Sys.down) + " \u2191" + Sys.fmt(Sys.up)
}
