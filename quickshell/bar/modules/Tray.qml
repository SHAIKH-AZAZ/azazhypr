import QtQuick
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "../components"
import "../services"

// System tray. left: activate, right: menu
Row {
    id: root
    property var bar
    spacing: 6
    anchors.verticalCenter: parent.verticalCenter

    Repeater {
        model: SystemTray.items
        IconImage {
            id: tray
            required property var modelData
            anchors.verticalCenter: parent.verticalCenter
            implicitSize: 18
            source: modelData.icon

            TrayMenu { id: menu; bar: root.bar; menuHandle: tray.modelData.menu; target: tray }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: m => {
                    if (m.button === Qt.LeftButton && !tray.modelData.onlyMenu) tray.modelData.activate();
                    else if (tray.modelData.hasMenu) { root.bar.drop = ""; menu.open() }
                    else tray.modelData.secondaryActivate();
                }
            }
        }
    }
}
