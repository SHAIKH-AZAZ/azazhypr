import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import "../components"
import "../modules"
import "../services"

// Dynamic island, top center over the bar (ideas from enhaoswen/Tide-island).
// One capsule morphs between states; only the capsule takes input (mask).
//   idle   date, or art + cava while playing      click: expand, right-click: play/pause, scroll: next/prev
//   open   media card (or clock + weather)         click outside / Esc: collapse
//   osd    volume / brightness (replaces windows/Osd.qml while Config.island)
// ipc: qs -p <bar> ipc call island toggle
PanelWindow {
    id: win

    required property var modelData
    screen: modelData

    anchors.top: true
    margins.top: 2
    implicitWidth: 460                       // biggest state + room for the morph
    implicitHeight: 200
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: Config.island && !Sys.barHidden
    mask: Region { item: cap }
    WlrLayershell.namespace: "quickshell-island"

    property bool open: false
    property string osdGlyph: "volume_up"
    property color osdTint: Theme.green
    property real osdValue: 0
    property bool ready: false
    readonly property var p: Sys.player
    readonly property string mode: osdTimer.running && !open ? "osd" : open ? "open" : "idle"

    function osd(g, c, v) {
        if (!ready) return;
        osdGlyph = g; osdTint = c; osdValue = v;
        osdTimer.restart();
    }

    Timer { id: osdTimer; interval: Config.osdTimeout }
    Timer { interval: 2000; running: true; onTriggered: win.ready = true }   // ignore startup churn
    Connections {
        target: Sys.sink ?? null
        function onVolumeChanged() { win.osd(Sys.sink.muted ? "volume_off" : "volume_up", Theme.green, Sys.sink.volume) }
        function onMutedChanged() { win.osd(Sys.sink.muted ? "volume_off" : "volume_up", Theme.green, Sys.sink.volume) }
    }
    Connections {
        target: Sys
        function onBrightChanged() { win.osd("brightness_high", Theme.yellow, Sys.bright / 100) }
    }
    // MPRIS only pushes position on seek; poll while the card shows it
    Timer {
        running: win.open && !!win.p?.isPlaying
        interval: 1000; repeat: true
        onTriggered: win.p.positionChanged()
    }

    HyprlandFocusGrab {
        windows: [win]
        active: win.open
        onCleared: win.open = false
    }
    SystemClock { id: clock; precision: SystemClock.Minutes }
    // first screen only: ipc targets must be unique
    IpcHandler {
        target: "island"
        enabled: win.screen === Quickshell.screens[0]
        function toggle(): void { win.open = !win.open }
    }

    Rectangle {
        id: cap
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0
        width: win.mode === "open" ? 420 : win.mode === "osd" ? 300 : win.p ? 200 : 140
        height: win.mode === "open" ? 150 : 32
        radius: win.mode === "open" ? 24 : height / 2
        color: Qt.alpha(Theme.bg, 0.97)
        border { width: 1; color: Theme.subtle }
        clip: true
        focus: win.open
        Keys.onEscapePressed: win.open = false

        // Tide's morph: one duration + OutQuint for every geometry property
        Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutQuint } }
        Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.OutQuint } }
        Behavior on radius { NumberAnimation { duration: 400; easing.type: Easing.OutQuint } }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: e => e.button === Qt.RightButton ? win.p?.togglePlaying() : (win.open = !win.open)
            onWheel: e => e.angleDelta.y > 0 ? win.p?.next() : win.p?.previous()
        }

        // ---------------- idle ----------------
        Item {
            anchors.fill: parent
            opacity: win.mode === "idle" ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 180 } }

            Txt {
                visible: !win.p
                anchors.centerIn: parent
                text: Qt.formatDateTime(clock.date, "ddd d MMM")
                font.bold: true
            }
            Row {
                visible: !!win.p
                anchors.centerIn: parent
                spacing: 10
                ClippingRectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 22; height: 22; radius: 11
                    color: Theme.subtle
                    Txt { anchors.centerIn: parent; icon: true; text: "music_note"; color: Theme.muted; font.pixelSize: 14 }
                    IconImage { anchors.fill: parent; source: win.p?.trackArtUrl ?? "" }
                }
                Cava { anchors.verticalCenter: parent.verticalCenter; bars: 14 }
            }
        }

        // ---------------- osd ----------------
        Row {
            anchors.centerIn: parent
            spacing: 12
            opacity: win.mode === "osd" ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 180 } }
            Txt { anchors.verticalCenter: parent.verticalCenter; icon: true; text: win.osdGlyph; color: win.osdTint; font.pixelSize: 18 }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 180; height: 6; radius: 3
                color: Theme.subtle
                Rectangle {
                    width: parent.width * Sys.clamp(win.osdValue); height: parent.height; radius: 3; color: win.osdTint
                    Behavior on width { NumberAnimation { duration: 120 } }
                }
            }
            Txt { anchors.verticalCenter: parent.verticalCenter; width: 36; text: Math.round(win.osdValue * 100) + "%"; font.pixelSize: 12 }
        }

        // ---------------- open: media ----------------
        Item {
            anchors { fill: parent; margins: 16 }
            opacity: win.mode === "open" && !!win.p ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 180 } }

            ClippingRectangle {
                id: art
                width: 84; height: 84; radius: 14
                color: Theme.subtle
                Txt { anchors.centerIn: parent; icon: true; text: "music_note"; color: Theme.muted; font.pixelSize: 40 }
                IconImage { anchors.fill: parent; source: win.p?.trackArtUrl ?? "" }
            }
            Column {
                anchors { left: art.right; leftMargin: 14; right: parent.right; top: art.top; topMargin: 6 }
                spacing: 2
                Txt { width: parent.width; text: win.p?.trackTitle ?? ""; font { bold: true; pixelSize: 15 } }
                Txt { width: parent.width; text: win.p?.trackArtist || win.p?.identity || ""; color: Theme.muted }
            }
            Row {
                anchors { left: art.right; leftMargin: 8; bottom: art.bottom }
                spacing: 4
                Btn { glyph: "skip_previous"; size: 22; onClicked: win.p?.previous() }
                Btn { glyph: win.p?.isPlaying ? "pause" : "play_arrow"; size: 26; onClicked: win.p?.togglePlaying() }
                Btn { glyph: "skip_next"; size: 22; onClicked: win.p?.next() }
            }
            // progress
            Item {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 14
                visible: (win.p?.length ?? 0) > 0
                Txt { id: pos; anchors.verticalCenter: parent.verticalCenter; text: Sys.fmtTime(win.p?.position); font.pixelSize: 10; color: Theme.muted }
                Txt { id: len; anchors { right: parent.right; verticalCenter: parent.verticalCenter } text: Sys.fmtTime(win.p?.length); font.pixelSize: 10; color: Theme.muted }
                Rectangle {
                    anchors { left: pos.right; right: len.left; margins: 8; verticalCenter: parent.verticalCenter }
                    height: 4; radius: 2
                    color: Theme.subtle
                    Rectangle {
                        height: parent.height; radius: 2; color: Theme.accent
                        width: parent.width * Sys.clamp((win.p?.position ?? 0) / Math.max(1, win.p?.length ?? 1))
                    }
                    MouseArea {
                        anchors { fill: parent; margins: -5 }
                        enabled: !!win.p?.canSeek
                        onClicked: e => win.p.position = Sys.clamp(e.x / width) * win.p.length
                    }
                }
            }
        }

        // ---------------- open: nothing playing ----------------
        Column {
            anchors.centerIn: parent
            spacing: 4
            opacity: win.mode === "open" && !win.p ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 180 } }
            Txt { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDateTime(clock.date, "hh:mm"); font { pixelSize: 40; bold: true } }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6
                Txt { text: Qt.formatDateTime(clock.date, "dddd, d MMMM"); color: Theme.muted }
                Txt { visible: !!Forecast.cur; icon: true; text: Forecast.cur ? Forecast.icon(Forecast.cur.weather_code, Forecast.cur.is_day === 1) : ""; color: Theme.muted; font.pixelSize: 15 }
                Txt { visible: !!Forecast.cur; text: Forecast.cur ? Math.round(Forecast.cur.temperature_2m) + "°" : ""; color: Theme.muted }
            }
        }
    }
}
