import QtQuick
import QtQuick.Layouts
import "../services"

Rectangle {
    id: pill
    property string text
    property bool primary: false
    property bool danger: false
    signal clicked
    implicitWidth: lbl.implicitWidth + 18
    implicitHeight: 26
    radius: 8
    color: primary ? Theme.accent : Theme.subtle
    opacity: pm.containsMouse ? 0.85 : 1
    Txt { id: lbl; anchors.centerIn: parent; text: pill.text; font.pixelSize: 11; color: pill.primary ? Theme.bg : pill.danger ? Theme.red : Theme.fg }
    MouseArea { id: pm; anchors.fill: parent; hoverEnabled: true; onClicked: pill.clicked() }
}
