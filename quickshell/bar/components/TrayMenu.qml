import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import "../services"

// Styled tray context menu (DBusMenu entries). Call open() on right click.
// Entries with children push a submenu; disabled entries render as muted section headers.
PopupWindow {
    id: root

    required property var bar
    required property var menuHandle     // SystemTrayItem.menu
    property Item target                 // icon the menu hangs off
    property var stack: []               // open submenu path
    property real ax: 0
    property real ay: 0
    readonly property int w: 300

    function open() {
        stack = [];
        const p = target.mapToItem(null, target.width / 2, target.height);
        ax = p.x;
        ay = p.y;
        visible = true;
    }
    function close() { visible = false }

    anchor.window: bar
    anchor.rect: Qt.rect(Math.max(4, Math.min(bar.width - w - 4, ax - w / 2)), ay + 8, 1, 1)
    implicitWidth: w
    implicitHeight: col.implicitHeight + 16
    visible: false
    color: "transparent"

    QsMenuOpener {
        id: opener
        menu: root.stack.length ? root.stack[root.stack.length - 1] : root.menuHandle
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.visible
        onCleared: root.close()
    }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Theme.bg
        border { width: 1; color: Theme.subtle }

        ColumnLayout {
            id: col
            anchors { fill: parent; margins: 8 }
            spacing: 0

            // back row inside a submenu
            Rectangle {
                visible: root.stack.length > 0
                Layout.fillWidth: true
                implicitHeight: 32
                radius: 8
                color: backMa.containsMouse ? Theme.subtle : "transparent"
                Txt { anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 10 } text: "   Back" }
                MouseArea { id: backMa; anchors.fill: parent; hoverEnabled: true; onClicked: root.stack = root.stack.slice(0, -1) }
            }

            Repeater {
                model: opener.children

                Item {
                    id: row
                    required property var modelData
                    readonly property bool checked: modelData.buttonType !== 0 && modelData.checkState === Qt.Checked

                    Layout.fillWidth: true
                    implicitHeight: modelData.isSeparator ? 9 : 32

                    Rectangle {
                        visible: row.modelData.isSeparator
                        anchors.centerIn: parent
                        width: parent.width - 8; height: 1
                        color: Theme.subtle
                    }

                    Rectangle {
                        visible: !row.modelData.isSeparator
                        anchors.fill: parent
                        radius: 8
                        color: ma.containsMouse && row.modelData.enabled ? Theme.subtle : "transparent"

                        RowLayout {
                            anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                            spacing: 8
                            Txt { visible: row.checked; text: ""; color: Theme.accent; font.pixelSize: 11 }
                            IconImage {
                                visible: !!row.modelData.icon
                                implicitSize: 16
                                source: row.modelData.icon ?? ""
                            }
                            Txt {
                                Layout.fillWidth: true
                                text: row.modelData.text
                                color: row.modelData.enabled ? Theme.fg : Theme.muted
                            }
                            Txt { visible: row.modelData.hasChildren; text: ""; color: Theme.muted; font.pixelSize: 11 }
                        }

                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (!row.modelData.enabled) return;
                                if (row.modelData.hasChildren) root.stack = [...root.stack, row.modelData];
                                else { row.modelData.triggered(); root.close() }
                            }
                        }
                    }
                }
            }
        }
    }
}
