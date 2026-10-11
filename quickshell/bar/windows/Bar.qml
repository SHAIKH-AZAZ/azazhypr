import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "../modules"
import "../services"

// Top bar, one per screen. Layout only: every module lives in modules/.
// Modules that open a dropdown call bar.toggle("<panel>", item).
PanelWindow {
    id: bar

    required property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true }
    margins { top: 2; left: 4; right: 4 }
    implicitHeight: 36
    color: "transparent"
    visible: !Sys.barHidden
    WlrLayershell.namespace: "quickshell-bar"
    // the calendar has a text field; other panels never need the keyboard
    WlrLayershell.keyboardFocus: (drop === "calendar" || drop === "weather") ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // ---- dropdown state ----
    property string drop: ""
    property real dropX: 0
    function toggle(name, item) {
        if (drop === name) { drop = ""; return }
        dropX = item.mapToItem(frame, item.width / 2, 0).x;
        drop = name;
    }

    IdleInhibitor { window: bar; enabled: Sys.inhibit }

    Dropdown { id: dd; bar: bar; name: bar.drop; cx: bar.dropX }
    HyprlandFocusGrab {
        windows: [bar, dd]
        active: bar.drop !== ""
        onCleared: bar.drop = ""
    }

    Rectangle {
        id: frame
        anchors.fill: parent
        radius: 12
        color: Qt.alpha(Theme.bg, 0.9)

        // ---------------- left ----------------
        Row {
            anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
            spacing: 4

            Dashboard { bar: bar }
            Clock { bar: bar }
            Rectangle { width: 1; height: 14; color: Theme.subtle; anchors.verticalCenter: parent.verticalCenter }
            Workspaces { screen: bar.screen }
        }

        // ---------------- center ----------------
        Cava { anchors.centerIn: parent }

        // ---------------- right ----------------
        Row {
            anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
            spacing: 14

            Row {   // status
                spacing: 2
                anchors.verticalCenter: parent.verticalCenter
                ActivityBtn { bar: bar }
                System { bar: bar }
                Updates { bar: bar }
                KbLayout {}
                Weather { bar: bar }
                Media { bar: bar }
                Bell { bar: bar }
                Idle {}
                Sunset {}
                Recorder {}
                NetStat {}
            }

            Tray { bar: bar }

            Row {   // connectivity
                spacing: 2
                anchors.verticalCenter: parent.verticalCenter
                Wifi { bar: bar }
                Bt { bar: bar }
            }

            Row {   // controls
                spacing: 2
                anchors.verticalCenter: parent.verticalCenter
                Brightness { bar: bar }
                Volume { bar: bar }
                Mic { bar: bar }
                Battery { bar: bar }
            }

            Power {}
        }
    }
}
