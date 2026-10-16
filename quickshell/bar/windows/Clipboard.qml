import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../components"
import "../services"

// Clipboard history (cliphist) in its own window.
// Toggle: qs -p ~/.config/quickshell/bar ipc call clipboard toggle
// Keys: type to filter, Up/Down (Ctrl+J/K) move, Enter copy, Ctrl+Del delete, Alt+Del wipe all, Esc close.
PanelWindow {
    id: win

    property bool open: false
    property var lines: []
    property var results: []
    property int sel: 0
    property int tick: 0            // bumps when new thumbnails land -> forces image reload
    readonly property string imgDir: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/qs-clip"
    readonly property var current: results[sel] ?? null
    property string fullText: ""

    onCurrentChanged: {
        if (current && !current.img) fullTimer.restart();
        else fullText = "";
    }

    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    anchors { top: true; bottom: true; left: true; right: true }
    visible: open
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-clipboard"

    function show() {
        input.text = "";
        sel = 0;
        open = true;
        list.running = true;
        Qt.callLater(() => input.forceActiveFocus());
    }
    function hide() { open = false }

    function refresh() {
        const q = input.text.trim().toLowerCase();
        const out = [];
        for (const line of lines) {
            const tab = line.indexOf("\t");
            const id = line.slice(0, tab), text = line.slice(tab + 1);
            if (q && !text.toLowerCase().includes(q)) continue;
            const img = text.startsWith("[[ binary data");
            out.push({
                id, line, img,
                title: img ? "Image  " + (text.match(/(\d+x\d+)/)?.[1] ?? "") : text.replace(/\s+/g, " ").trim().slice(0, 140),
                sub: img ? text.replace(/[\[\]]/g, "").trim() : "",
                imgPath: img ? imgDir + "/" + id + ".png" : ""
            });
            if (out.length >= 100) break;
        }
        results = out;
        sel = Math.min(sel, Math.max(0, out.length - 1));
    }

    function copy(r) {
        Sys.run("sh", "-c", 'cliphist decode "$1" | wl-copy', "sh", r.id);
        hide();
    }
    function remove(r) {
        Sys.run("sh", "-c", 'printf "%s\n" "$1" | cliphist delete', "sh", r.line);
        lines = lines.filter(l => l !== r.line);
        refresh();
    }
    function wipe() {
        Sys.run("cliphist", "wipe");
        lines = [];
        refresh();
    }

    Process {
        id: list
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                win.lines = text.split("\n").filter(l => l.length);
                win.sel = 0;
                win.refresh();
                images.running = true;
            }
        }
    }
    // decode the newest image entries to files for thumbnails + preview
    Process {
        id: images
        command: ["sh", Quickshell.shellPath("scripts/clipimg.sh"), win.imgDir]
        onRunningChanged: if (!running && win.open) { win.tick++; win.refresh() }
    }

    // full text of the selected entry (the list only has a truncated preview)
    Timer { id: fullTimer; interval: 80; onTriggered: { full.running = false; full.running = true } }
    Process {
        id: full
        command: ["cliphist", "decode", win.current?.id ?? "0"]
        stdout: StdioCollector { onStreamFinished: win.fullText = text.slice(0, 4000) }
    }

    IpcHandler {
        target: "clipboard"
        function toggle(): void { win.open ? win.hide() : win.show() }
    }

    MouseArea { anchors.fill: parent; onClicked: win.hide() }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(920, win.width - 80); height: Math.min(880, win.height - 80)
        radius: 14
        color: Theme.bg
        border { width: 1; color: Theme.subtle }

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors { fill: parent; margins: 16 }
            spacing: 12

            // ---- search ----
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 44
                radius: 10
                color: Qt.alpha(Theme.subtle, 0.5)

                RowLayout {
                    anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                    spacing: 10
                    Txt { icon: true; text: "content_paste"; color: Theme.accent; font.pixelSize: 16 }
                    TextInput {
                        id: input
                        Layout.fillWidth: true
                        color: Theme.fg
                        selectionColor: Theme.accent
                        selectedTextColor: Theme.bg
                        font { family: Theme.font; pixelSize: 15 }
                        clip: true
                        onTextChanged: { win.sel = 0; win.refresh() }

                        Text {
                            visible: !input.text
                            text: "Search clipboard..."
                            color: Theme.muted
                            font: input.font
                        }

                        Keys.onPressed: e => {
                            const ctrl = e.modifiers & Qt.ControlModifier;
                            if (e.key === Qt.Key_Escape) win.hide();
                            else if (e.key === Qt.Key_Delete) {
                                if (e.modifiers & Qt.AltModifier) win.wipe();
                                else if (win.current) win.remove(win.current);
                            } else if (e.key === Qt.Key_Down || (ctrl && e.key === Qt.Key_J))
                                win.sel = Math.min(win.sel + 1, win.results.length - 1);
                            else if (e.key === Qt.Key_Up || (ctrl && e.key === Qt.Key_K))
                                win.sel = Math.max(win.sel - 1, 0);
                            else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                                if (win.current) win.copy(win.current);
                            } else return;
                            e.accepted = true;
                        }
                    }
                    Txt { text: win.results.length + " items"; color: Theme.muted; font.pixelSize: 11 }
                }
            }

            // ---- preview (top): image, or full text ----
            Rectangle {
                id: preview
                Layout.fillWidth: true
                Layout.preferredHeight: 440
                radius: 12
                color: Qt.alpha(Theme.subtle, 0.45)
                clip: true

                Image {
                    anchors { fill: parent; margins: 10 }
                    visible: !!win.current?.img
                    source: win.current?.img ? "file://" + win.current.imgPath + "?" + win.tick : ""
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: false
                }
                Flickable {
                    anchors { fill: parent; margins: 12 }
                    visible: !!win.current && !win.current.img
                    contentHeight: body.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    Text {
                        id: body
                        width: parent.width
                        text: win.fullText || win.current?.title || ""
                        wrapMode: Text.Wrap
                        color: Theme.fg
                        font { family: Theme.font; pixelSize: 14 }
                    }
                }
                Txt {
                    anchors.centerIn: parent
                    visible: !win.current
                    color: Theme.muted
                    text: win.lines.length === 0 ? "Clipboard history is empty" : "No matches"
                }
                // size/kind tag
                Rectangle {
                    visible: !!win.current
                    anchors { right: parent.right; top: parent.top; margins: 10 }
                    width: tag.implicitWidth + 16; height: 22; radius: 6
                    color: Qt.alpha(Theme.bg, 0.8)
                    Txt {
                        id: tag
                        anchors.centerIn: parent
                        font.pixelSize: 11
                        color: Theme.accent
                        text: win.current?.img ? (win.current.title.replace("Image", "").trim() + " px") : ((win.fullText || "").length + " chars")
                    }
                }
            }

            // ---- list ----
            ListView {
                id: view
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                model: win.results
                currentIndex: win.sel
                boundsBehavior: Flickable.StopAtBounds
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    height: 60
                    radius: 10
                    color: index === win.sel ? Theme.accent : "transparent"

                    RowLayout {
                        anchors { fill: parent; leftMargin: 8; rightMargin: 10 }
                        spacing: 12
                        Rectangle {
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            radius: 8
                            color: Qt.alpha(Theme.subtle, 0.6)
                            clip: true
                            Image {
                                anchors.fill: parent
                                visible: row.modelData.img
                                source: row.modelData.img ? "file://" + row.modelData.imgPath + "?" + win.tick : ""
                                fillMode: Image.PreserveAspectCrop
                                sourceSize.width: 96
                                asynchronous: true
                                cache: false
                            }
                            Txt {
                                anchors.centerIn: parent
                                visible: !row.modelData.img
                                icon: true
                                text: "content_copy"
                                color: Theme.fg
                                font.pixelSize: 18
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Txt { Layout.fillWidth: true; text: row.modelData.title; color: row.index === win.sel ? Theme.bg : Theme.fg; font.pixelSize: 14 }
                            Txt {
                                visible: text !== ""
                                Layout.fillWidth: true
                                text: row.modelData.sub
                                color: row.index === win.sel ? Theme.bg : Theme.muted
                                font.pixelSize: 11
                            }
                        }
                    }
                    MouseArea { anchors.fill: parent; onClicked: win.copy(row.modelData) }
                }
            }

            Txt {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: "Enter copy   \u00b7   Ctrl+Del delete   \u00b7   Alt+Del wipe all   \u00b7   Esc close"
                color: Theme.muted
                font.pixelSize: 11
            }
        }
    }
}
