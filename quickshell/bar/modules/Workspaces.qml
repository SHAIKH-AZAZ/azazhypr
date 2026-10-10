import QtQuick
import Quickshell.Hyprland
import "../components"
import "../services"

// Workspaces 1-5 + any higher occupied one, active gets an accent pill
Row {
    id: root
    property var screen
    spacing: 4
    anchors.verticalCenter: parent.verticalCenter

    readonly property var mon: Hyprland.monitorFor(screen)
    readonly property var ids: {
        const s = new Set([1, 2, 3, 4, 5]);
        for (const w of Hyprland.workspaces.values)
            if (w.id > 0 && w.monitor === mon) s.add(w.id);
        return [...s].sort((a, b) => a - b);
    }

    Repeater {
        model: root.ids
        Rectangle {
            id: ws
            required property int modelData
            readonly property bool active: root.mon?.activeWorkspace?.id === modelData
            readonly property bool urgent: Hyprland.workspaces.values.some(w => w.id === modelData && w.urgent)
            anchors.verticalCenter: parent.verticalCenter
            width: 26; height: 26; radius: 8
            color: active ? Theme.accent : "transparent"
            Text {
                anchors.centerIn: parent
                text: ws.modelData
                font { family: Theme.font; pixelSize: 15; bold: ws.active }
                color: ws.active ? Theme.bg : ws.urgent ? Theme.red : Theme.fg
            }
            MouseArea { anchors.fill: parent; onClicked: Sys.gotoWorkspace(ws.modelData) }
        }
    }
}
