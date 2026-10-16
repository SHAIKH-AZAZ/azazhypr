import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../components"
import "../services"

// Wallpaper picker: a carousel of thumbnails with live preview.
// Toggle: qs -p ~/.config/quickshell/bar ipc call wallpaper toggle   (bound to Super+W)
// Type to filter by file/folder name (all words must match). Left/Right (Up/Down) move,
// PageUp/PageDown jump 5, Home/End, Ctrl+R random, Enter apply, Esc clears the search, then cancels.
// Moving the selection sets the wallpaper right away (no wallust); Esc puts the old one back.
// Enter hands the file to WallpaperSelect.sh --apply (wallust, reload, startup config).
Scope {
PanelWindow {
    id: win

    property bool open: false
    property var all: []                // every wallpaper found
    property var files: []              // `all` filtered by the search box
    property int idx: 0
    property bool ready: false          // false while the list loads, so the first idx set is not previewed
    property bool previewed: false
    property string original: ""
    readonly property string current: files[idx] ?? ""
    readonly property string monitor: Hyprland.focusedMonitor?.name ?? ""
    readonly property real cell: 260

    screen: Quickshell.screens.find(s => s.name === monitor) ?? Quickshell.screens[0]
    // only as big as the picker: a full-screen transparent layer made the compositor blend the whole
    // screen on every frame, which is expensive on integrated GPUs
    anchors { top: true }
    margins { top: 56 }
    implicitWidth: Math.min(1300, (screen?.width ?? 1920) - 80)
    implicitHeight: 300
    visible: open
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-wallpaper"

    function show() {
        original = Theme.c.wallpaper ?? "";   // refined by `awww query` below
        previewed = false;
        ready = false;
        open = true;
        search.text = "";
        scan.running = true;
        query.running = true;
        if (Config.wallpaperThumbs && !thumbsStarted) { thumbsStarted = true; thumbs.running = true }
        Qt.callLater(() => search.forceActiveFocus());
    }
    // path below the wallpapers folder, lowercase: what the search matches against
    function rel(f) { const i = f.indexOf("/wallpapers/"); return (i >= 0 ? f.slice(i + 12) : f).toLowerCase() }
    // re-apply the search, keeping `keep` (default: the selected file) selected when it still matches
    function refilter(keep) {
        const prev = keep ?? current;
        const terms = search.text.toLowerCase().split(/\s+/).filter(t => t);
        files = terms.length ? all.filter(f => { const r = rel(f); return terms.every(t => r.includes(t)) }) : all;
        const i = files.indexOf(prev);
        idx = i >= 0 ? i : 0;
    }
    // cancel = put the wallpaper that was active back
    function hide(cancel) {
        open = false;
        previewTimer.stop();
        if (cancel && previewed && original) setWall(original);
    }
    function apply() {
        if (!current) return;
        const f = current;
        hide(false);
        setWall(f);     // dissolve into it (when Config.wallpaperDissolve), awww switches underneath
        // QS_WALL_FX=1: the script skips awww's own transition, the overlay is the transition
        Sys.run("env", "QS_WALL_FX=1", "sh", Quickshell.env("HOME") + "/.config/hypr/UserScripts/WallpaperSelect.sh", "--apply", f);
    }
    function move(d) { idx = Math.max(0, Math.min(files.length - 1, idx + d)) }
    // one awww at a time, last target wins (parallel calls could finish out of order and leave a stale wallpaper)
    property string wallTarget: ""
    property string wallDone: ""
    property string shown: ""           // what awww currently displays (for the dissolve's "from" side)
    property bool dissolvePending: false
    function setWall(f, ms) {
        wallTarget = f;
        if (Config.wallpaperDissolve && shown && f !== shown) {
            // overlay first (it looks identical to the wallpaper), then switch the real one under it
            dissolvePending = true;
            // drift direction follows the picker: forward through the list = +1
            const a = all.indexOf(shown), b = all.indexOf(f);
            fx.run(shown, f, ms, (a < 0 || b < 0 || b >= a) ? 1 : -1);
            shown = f;
        } else {
            shown = f;
            pump();
        }
    }
    Connections {
        target: fx
        function onStarted() { if (win.dissolvePending) { win.dissolvePending = false; win.pump(); win.syncFx() } }
    }
    // tell the overlay when the real wallpaper underneath matches the target
    function syncFx() { if (!wallProc.running && wallTarget === wallDone) fx.ready = true }
    function pump() {
        if (wallProc.running || wallTarget === wallDone) return;
        wallDone = wallTarget;
        wallProc.command = ["awww", "img", "-o", monitor, wallTarget, "--transition-type", "none"];
        wallProc.running = true;
    }
    Process { id: wallProc; onRunningChanged: if (!running) { win.pump(); win.syncFx() } }

    // the wallpaper actually on screen (qml_color.json can lag behind wallust)
    Process {
        id: query
        command: ["sh", "-c", "awww query | sed -n '1s/.*image: //p'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim();
                if (p) { win.shown = p; if (!win.previewed) win.original = p; }
                if (win.pendingSet) { const f = win.pendingSet; win.pendingSet = ""; win.setWall(f) }
            }
        }
    }

    // live preview while browsing is optional: off = the wallpaper only changes (with the effect) on Enter / click
    onIdxChanged: if (open && ready && Config.wallpaperLivePreview) previewTimer.restart()
    Timer {
        id: previewTimer
        interval: 220
        onTriggered: { win.previewed = true; win.setWall(win.current) }
    }

    Process {
        id: scan
        command: ["sh", Quickshell.shellPath("scripts/wallpapers.sh")]
        stdout: StdioCollector {
            onStreamFinished: {
                win.all = text.split("\n").filter(l => l.length);
                win.refilter(win.original);
                win.ready = true;
            }
        }
    }

    readonly property string thumbDir: Quickshell.env("HOME") + "/.cache/qs-wallpaper-thumbs"
    property bool thumbsStarted: false
    Process {
        id: thumbs
        command: ["nice", "-n", "19", "sh", Quickshell.shellPath("scripts/thumbs.sh"), win.thumbDir]
    }

    property string pendingSet: ""
    IpcHandler {
        target: "wallpaper"
        function toggle(): void { win.open ? win.hide(true) : win.show() }
        // qs -p <bar> ipc call wallpaper set /path/to/image.jpg   (dissolves into it; no wallust)
        function set(path: string): void { win.pendingSet = path; query.running = true }
    }

    // click outside = cancel
    HyprlandFocusGrab {
        windows: [win]
        active: win.open
        onCleared: win.hide(true)
    }

    Rectangle {
        id: panel
        anchors.fill: parent
        radius: 30
        color: "transparent"        // only the cards float over the wallpaper

        MouseArea {
            anchors.fill: parent
            onWheel: e => win.move(e.angleDelta.y < 0 || e.angleDelta.x < 0 ? 1 : -1)
        }


        // search box: always focused, so typing filters; arrows/Enter/Esc are handled here too
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 12
            width: Math.min(360, parent.width - 340)
            height: 32
            radius: 16
            color: Qt.alpha("#000000", 0.7)

            // underline instead of a box
            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: search.activeFocus ? 2 : 1
                color: search.activeFocus ? Theme.accent : Theme.subtle
            }

            Txt { icon: true; x: 12; anchors.verticalCenter: parent.verticalCenter; text: "search"; color: Theme.muted }
            TextInput {
                id: search
                anchors { fill: parent; leftMargin: 34; rightMargin: 34 }
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.fg
                selectionColor: Theme.accent
                selectedTextColor: Theme.bg
                clip: true
                font { family: Theme.font; pixelSize: 13 }
                onTextChanged: if (win.open) win.refilter()

                Keys.onPressed: e => {
                    switch (e.key) {
                    case Qt.Key_Left: case Qt.Key_Up: win.move(-1); break;
                    case Qt.Key_Right: case Qt.Key_Down: win.move(1); break;
                    case Qt.Key_PageUp: win.move(-5); break;
                    case Qt.Key_PageDown: win.move(5); break;
                    case Qt.Key_Home: win.idx = 0; break;
                    case Qt.Key_End: win.idx = Math.max(0, win.files.length - 1); break;
                    case Qt.Key_R:
                        if (!(e.modifiers & Qt.ControlModifier)) return;
                        win.idx = Math.floor(Math.random() * win.files.length);
                        break;
                    case Qt.Key_Return: case Qt.Key_Enter: win.apply(); break;
                    case Qt.Key_Escape:
                        if (search.text !== "") search.text = ""; else win.hide(true);
                        break;
                    default: return;
                    }
                    e.accepted = true;
                }
            }
            Txt {
                anchors { left: parent.left; leftMargin: 34; verticalCenter: parent.verticalCenter }
                visible: search.text === ""
                text: "Search wallpapers…"
                color: Theme.fg
                opacity: 0.8
                font.pixelSize: 13
                }
            Txt {   // clear
                icon: true
                anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                visible: search.text !== ""
                text: "close"
                color: clearMa.containsMouse ? Theme.red : Theme.muted
                MouseArea { id: clearMa; anchors { fill: parent; margins: -6 } hoverEnabled: true; onClicked: search.text = "" }
            }
        }

        MoltenArc {
            id: list
            anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: 52 }
            height: 206
            model: win.files
            index: win.idx
            thumbDir: Config.wallpaperThumbs ? win.thumbDir : ""
            onPicked: i => win.idx = i
            onActivated: win.apply()
        }

        Txt {
            anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; verticalCenterOffset: -6 }
            visible: win.ready && win.files.length === 0
            text: search.text ? "No wallpapers match \u201c" + search.text + "\u201d" : "No wallpapers found"
            color: Theme.muted
            font.pixelSize: 14
        }

        // footer: small pills so the text stays readable over any window or wallpaper
        Rectangle {
            x: 22
            anchors.bottom: parent.bottom; anchors.bottomMargin: 12
            width: Math.min(parent.width / 2, leftFoot.implicitWidth + 24); height: 28; radius: 14
            color: Qt.alpha("#000000", 0.6)
            visible: leftFoot.text !== ""
        }
        Rectangle {
            anchors { right: parent.right; rightMargin: 22; bottom: parent.bottom; bottomMargin: 12 }
            width: rightFoot.implicitWidth + 24; height: 28; radius: 14
            color: Qt.alpha("#000000", 0.6)
        }
        Txt {
            id: leftFoot
            x: 34
            anchors.bottom: parent.bottom; anchors.bottomMargin: 18
            width: Math.min(parent.width / 2 - 24, implicitWidth)
            elide: Text.ElideMiddle
            text: win.current ? win.rel(win.current) : (win.ready ? "" : "Loading…")
            color: Theme.fg
            font.pixelSize: 12
        }
        Txt {
            id: rightFoot
            anchors { right: parent.right; rightMargin: 34; bottom: parent.bottom; bottomMargin: 18 }
            text: (win.files.length ? (win.idx + 1) + "/" + win.files.length : "0/0")
                + (search.text && win.all.length ? " of " + win.all.length : "") + "  ·  Ctrl+R random  ·  Enter to apply"
            color: Theme.fg
            font.pixelSize: 12
            style: Text.Outline; styleColor: Qt.alpha("#000000", 0.8)
        }
    }
}

WallpaperFx { id: fx; monitor: win.monitor }
}
