import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import "../components"
import "../services"

// App launcher (rofi replacement). Toggle with:
//   qs -p ~/.config/quickshell/bar ipc call launcher toggle
// Keys: type to filter, Up/Down (Ctrl+J/K) move, Enter run, Tab/Shift+Tab category, Esc close.
PanelWindow {
    id: win

    property bool open: false
    property int cat: 0               // index into cats
    property var results: []
    property int sel: 0
    readonly property string home: Quickshell.env("HOME")
    readonly property var cats: [
        { name: "apps", glyph: "" },
        { name: "files", glyph: "" },
        { name: "term", glyph: "" },
        { name: "window", glyph: "\uf2d0" }
    ]

    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    anchors { top: true; bottom: true; left: true; right: true }
    visible: open
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-launcher"

    function show() {
        cat = 0;
        input.text = "";
        Hyprland.refreshToplevels();
        open = true;
        refresh();
        Qt.callLater(() => input.forceActiveFocus());
    }
    function hide() { open = false }

    function launch(e) {
        if (e.runInTerminal) Sys.run(Config.terminal, "-e", ...e.command);
        else e.execute();
    }

    function refresh() {
        const q = input.text.trim().toLowerCase();
        sel = 0;
        if (cat === 0) {
            const out = [];
            for (const e of DesktopEntries.applications.values) {
                if (e.noDisplay) continue;
                const n = e.name.toLowerCase();
                let sc = 0;
                if (q) {
                    sc = n.startsWith(q) ? 3 : n.includes(q) ? 2
                        : ((e.genericName ?? "") + " " + (e.keywords ?? []).join(" ")).toLowerCase().includes(q) ? 1 : -1;
                    if (sc < 0) continue;
                }
                out.push({
                    sc, title: e.name, sub: e.genericName || e.comment || "",
                    icon: Quickshell.iconPath(e.icon, true) ?? "",
                    run: () => win.launch(e)
                });
            }
            out.sort((a, b) => b.sc - a.sc || a.title.localeCompare(b.title));
            results = out.slice(0, 60);
        } else if (cat === 1) {
            if (q.length < 2) { results = []; return }
            debounce.restart();
        } else if (cat === 2) {
            const cmd = input.text.trim();
            results = cmd ? [{
                title: cmd, sub: "run in " + Config.terminal, glyph: "",
                run: () => Sys.run(Config.terminal, "-e", "sh", "-c", cmd + "; exec \"$SHELL\"")
            }] : [];
        } else {
            const out = [];
            for (const t of Hyprland.toplevels.values) {
                const title = t.title ?? "", cls = t.lastIpcObject?.class ?? "";
                if (q && !(title + " " + cls).toLowerCase().includes(q)) continue;
                out.push({ title: title || cls, sub: cls, glyph: "", run: () => Sys.focusWindow(t.address) });
            }
            results = out;
        }
    }

    // ---- file search (fd) ----
    Timer {
        id: debounce
        interval: 150
        onTriggered: {
            finder.running = false;
            finder.command = ["fd", "-F", "-i", "--max-results", "50", input.text.trim(), win.home];
            finder.running = true;
        }
    }
    Process {
        id: finder
        stdout: StdioCollector {
            onStreamFinished: {
                if (win.cat !== 1) return;
                const out = [];
                for (const l of text.split("\n")) {
                    if (!l) continue;
                    const dir = l.endsWith("/");
                    out.push({
                        title: l.replace(/\/$/, "").split("/").pop(),
                        sub: l.replace(win.home, "~"),
                        glyph: dir ? "" : "",
                        run: () => Sys.run("xdg-open", l)
                    });
                }
                win.results = out;
            }
        }
    }

    // app list can still be loading when first opened
    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() { if (win.open && win.cat === 0) win.refresh() }
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { win.open ? win.hide() : win.show() }
        function show(): void { win.show() }
        function hide(): void { win.hide() }
    }

    // click outside closes
    MouseArea { anchors.fill: parent; onClicked: win.hide() }

    Rectangle {
        anchors.centerIn: parent
        width: 740; height: 460
        radius: 14
        color: Theme.bg
        border { width: 1; color: Theme.subtle }

        MouseArea { anchors.fill: parent }   // swallow clicks inside

        ColumnLayout {
            anchors { fill: parent; margins: 16 }
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 44
                radius: 10
                color: Qt.alpha(Theme.subtle, 0.5)

                RowLayout {
                    anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                    spacing: 10
                    Txt { text: ""; color: Theme.muted; font.pixelSize: 16 }
                    TextInput {
                        id: input
                        Layout.fillWidth: true
                        color: Theme.fg
                        selectionColor: Theme.accent
                        selectedTextColor: Theme.bg
                        font { family: Theme.font; pixelSize: 15 }
                        clip: true
                        onTextChanged: win.refresh()

                        Text {
                            visible: !input.text
                            text: "Search..."
                            color: Theme.muted
                            font: input.font
                        }

                        Keys.onPressed: e => {
                            const ctrl = e.modifiers & Qt.ControlModifier;
                            if (e.key === Qt.Key_Escape) { win.hide(); e.accepted = true }
                            else if (e.key === Qt.Key_Down || (ctrl && e.key === Qt.Key_J)) {
                                win.sel = Math.min(win.sel + 1, win.results.length - 1);
                                e.accepted = true;
                            } else if (e.key === Qt.Key_Up || (ctrl && e.key === Qt.Key_K)) {
                                win.sel = Math.max(win.sel - 1, 0);
                                e.accepted = true;
                            } else if (e.key === Qt.Key_Tab) {
                                win.cat = (win.cat + 1) % win.cats.length; win.refresh(); e.accepted = true;
                            } else if (e.key === Qt.Key_Backtab) {
                                win.cat = (win.cat + win.cats.length - 1) % win.cats.length; win.refresh(); e.accepted = true;
                            } else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                                const r = win.results[win.sel];
                                if (r) { r.run(); win.hide() }
                                e.accepted = true;
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                // categories
                ColumnLayout {
                    Layout.fillWidth: false
                    Layout.minimumWidth: 120
                    Layout.maximumWidth: 120
                    Layout.fillHeight: true
                    spacing: 8
                    Repeater {
                        model: win.cats
                        Rectangle {
                            required property var modelData
                            required property int index
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 10
                            color: win.cat === index ? Theme.accent : "transparent"
                            border { width: win.cat === index ? 0 : 1; color: Theme.subtle }
                            Row {
                                anchors.centerIn: parent
                                spacing: 8
                                Txt { text: modelData.glyph; color: win.cat === index ? Theme.bg : Theme.fg; font.pixelSize: 16 }
                                Txt { text: modelData.name; color: win.cat === index ? Theme.bg : Theme.fg }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { win.cat = index; win.refresh(); input.forceActiveFocus() }
                            }
                        }
                    }
                }

                // results
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 10
                    color: "transparent"
                    border { width: 1; color: Theme.subtle }

                    Txt {
                        anchors.centerIn: parent
                        visible: win.results.length === 0
                        color: Theme.muted
                        text: win.cat === 1 && input.text.trim().length < 2 ? "Type 2+ characters"
                            : win.cat === 2 ? "Type a command" : "No results"
                    }

                    ListView {
                        id: list
                        anchors { fill: parent; margins: 6 }
                        clip: true
                        spacing: 2
                        model: win.results
                        currentIndex: win.sel
                        onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
                        delegate: Rectangle {
                            id: row
                            required property var modelData
                            required property int index
                            width: ListView.view.width
                            height: 44
                            radius: 8
                            color: index === win.sel ? Theme.accent : "transparent"
                            RowLayout {
                                anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                                spacing: 10
                                IconImage {
                                    visible: !!row.modelData.icon
                                    implicitSize: 26
                                    source: row.modelData.icon ?? ""
                                }
                                Txt {
                                    visible: !row.modelData.icon
                                    Layout.preferredWidth: 26
                                    horizontalAlignment: Text.AlignHCenter
                                    text: row.modelData.glyph ?? ""
                                    color: row.index === win.sel ? Theme.bg : Theme.fg
                                    font.pixelSize: 18
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    Txt { Layout.fillWidth: true; text: row.modelData.title; color: row.index === win.sel ? Theme.bg : Theme.fg; font.pixelSize: 14 }
                                    Txt {
                                        visible: text !== ""
                                        Layout.fillWidth: true
                                        text: row.modelData.sub ?? ""
                                        color: row.index === win.sel ? Theme.bg : Theme.muted
                                        font.pixelSize: 11
                                    }
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { row.modelData.run(); win.hide() }
                            }
                        }
                    }
                }
            }
        }
    }
}
