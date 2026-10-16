import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../components"
import "../services"

// Screenshot menu: fullscreen / area / window / 5s / 10s. Runs hypr/scripts/ScreenShot.sh.
// Toggle: qs -p ~/.config/quickshell/bar ipc call screenshot toggle
// Keys: Left/Right (or Tab) select, Enter run, Esc close.
PanelWindow {
    id: win

    property bool open: false
    property int sel: 0
    property string dir: ""
    property string latest: ""
    property string pending: ""     // flag to run once the panel is gone

    readonly property var modes: [
        { glyph: "desktop_windows", flag: "--now",    label: "" },
        { glyph: "crop", flag: "--area",   label: "" },
        { glyph: "web_asset", flag: "--active", label: "" },
        { glyph: "",       flag: "--in5",    label: "5s" },
        { glyph: "",       flag: "--in10",   label: "10" }
    ]

    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    anchors { top: true; bottom: true; left: true; right: true }
    visible: open
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-screenshot"

    function show() {
        sel = 0;
        info.running = true;
        open = true;
        Qt.callLater(() => keys.forceActiveFocus());
    }
    function hide() { open = false }
    function run(i) {
        pending = modes[i].flag;
        hide();
        delay.restart();     // let the compositor drop the panel before grabbing
    }

    Timer {
        id: delay
        interval: 350
        onTriggered: Sys.run(Config.screenshotScript, win.pending)
    }

    // screenshot dir + newest file for the preview banner
    Process {
        id: info
        command: ["sh", "-c", 'd="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")/Screenshots"; echo "$d"; ls -t "$d"/* 2>/dev/null | head -1']
        stdout: StdioCollector {
            onStreamFinished: {
                const l = text.split("\n");
                win.dir = l[0] ?? "";
                win.latest = l[1] ?? "";
            }
        }
    }

    IpcHandler {
        target: "screenshot"
        function toggle(): void { win.open ? win.hide() : win.show() }
    }

    MouseArea { anchors.fill: parent; onClicked: win.hide() }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 520
        height: banner.height + tiles.implicitHeight + footer.implicitHeight + 48
        radius: 16
        color: Theme.bg
        border { width: 1; color: Theme.accent }

        MouseArea { anchors.fill: parent }

        FocusScope {
            id: keys
            anchors.fill: parent
            Keys.onPressed: e => {
                if (e.key === Qt.Key_Escape) win.hide();
                else if (e.key === Qt.Key_Right || e.key === Qt.Key_Tab) win.sel = (win.sel + 1) % win.modes.length;
                else if (e.key === Qt.Key_Left || e.key === Qt.Key_Backtab) win.sel = (win.sel + win.modes.length - 1) % win.modes.length;
                else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) win.run(win.sel);
                else return;
                e.accepted = true;
            }
        }

        ColumnLayout {
            anchors { fill: parent; margins: 12 }
            spacing: 12

            // banner: newest screenshot
            Rectangle {
                id: banner
                Layout.fillWidth: true
                Layout.preferredHeight: 170
                radius: 12
                clip: true
                color: Qt.alpha(Theme.subtle, 0.6)

                Image {
                    anchors.fill: parent
                    source: win.latest ? "file://" + win.latest : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: status === Image.Ready
                }
                Txt {
                    anchors.centerIn: parent
                    visible: !win.latest
                    icon: true
                    text: "photo_camera"
                    color: Theme.muted
                    font.pixelSize: 40
                }
                Rectangle {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 14 }
                    width: tag.implicitWidth + 20; height: 26; radius: 6
                    color: Theme.accent
                    Txt { id: tag; anchors.centerIn: parent; text: "Screenshot"; color: Theme.bg; font.bold: true }
                }
            }

            RowLayout {
                id: tiles
                Layout.fillWidth: true
                spacing: 10
                Repeater {
                    model: win.modes
                    Rectangle {
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        implicitHeight: 70
                        radius: 12
                        color: win.sel === index ? Theme.accent : Qt.alpha(Theme.subtle, 0.6)
                        opacity: tileMa.containsMouse && win.sel !== index ? 0.85 : 1
                        Txt {
                            anchors.centerIn: parent
                            icon: !!modelData.glyph
                            text: modelData.glyph || modelData.label
                            color: win.sel === index ? Theme.bg : Theme.fg
                            font { pixelSize: modelData.glyph ? 28 : 22; bold: !modelData.glyph }
                        }
                        MouseArea {
                            id: tileMa
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: win.sel = index
                            onClicked: win.run(index)
                        }
                    }
                }
            }

            Txt {
                id: footer
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: "Directory :: " + win.dir
                color: Theme.muted
                font.pixelSize: 11
            }
        }
    }
}
