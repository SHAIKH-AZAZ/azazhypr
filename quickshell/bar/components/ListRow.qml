import QtQuick
import QtQuick.Layouts
import "../services"

Rectangle {
    id: r
    property string text
    property string sub
    property bool on: false
    signal clicked
    Layout.fillWidth: true
    implicitHeight: 38
    radius: 8
    color: ma.containsMouse ? Theme.subtle : "transparent"
    ColumnLayout {
        anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
        spacing: 0
        Txt { Layout.fillWidth: true; text: r.text; color: r.on ? Theme.accent : Theme.fg; Layout.alignment: Qt.AlignVCenter }
        Txt { visible: r.sub !== ""; Layout.fillWidth: true; text: r.sub; color: Theme.muted; font.pixelSize: 11 }
    }
    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: r.clicked() }
}
