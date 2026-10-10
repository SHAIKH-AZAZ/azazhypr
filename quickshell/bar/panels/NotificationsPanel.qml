import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import "../components"
import "../services"

ColumnLayout {
    signal close()

    spacing: 6
    RowLayout {
        Txt { Layout.fillWidth: true; text: "Notifications"; font.bold: true }
        Txt {
            text: Notifs.dnd ? "DND on" : "DND off"
            color: Notifs.dnd ? Theme.accent : Theme.muted
            MouseArea { anchors { fill: parent; margins: -6 } onClicked: Notifs.dnd = !Notifs.dnd }
        }
        Txt {
            text: "  Clear"
            color: Theme.muted
            MouseArea { anchors { fill: parent; margins: -6 } onClicked: Notifs.clear() }
        }
    }
    Txt { visible: Notifs.list.values.length === 0; text: "No notifications"; color: Theme.muted }
    ListView {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, 360)
        clip: true
        spacing: 4
        model: Notifs.list
        delegate: Rectangle {
            id: item
            required property var modelData
            width: ListView.view.width
            height: col.implicitHeight + 16
            radius: 8
            color: Theme.subtle
            ColumnLayout {
                id: col
                anchors { fill: parent; margins: 8 }
                spacing: 2
                Txt { Layout.fillWidth: true; text: item.modelData.summary; font.bold: true }
                Txt {
                    Layout.fillWidth: true
                    visible: text !== ""
                    text: item.modelData.body
                    color: Theme.muted
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                }
            }
            MouseArea { anchors.fill: parent; onClicked: item.modelData.dismiss() }
        }
    }
}
