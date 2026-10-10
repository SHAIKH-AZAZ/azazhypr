import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import "../components"
import "../services"

// wayle-style dashboard: toggles, volume, now playing, battery/net, system, session.
ColumnLayout {
    id: root
    signal close()
    spacing: 8

    readonly property var player: Sys.player
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var bat: UPower.displayDevice

    // MPRIS position doesn't notify on its own
    Timer {
        interval: 1000; repeat: true
        running: !!root.player && root.player.isPlaying
        onTriggered: root.player.positionChanged()
    }

    RowLayout {
        spacing: 8
        Txt { text: ""; font.pixelSize: 16 }
        Txt { Layout.fillWidth: true; text: "Dashboard"; font.bold: true }
    }

    // ---- quick toggles ----
    Card {
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            rowSpacing: 6
            QuickToggle { glyph: ""; text: "WiFi"; on: Sys.wifiRadio; onClicked: Sys.toggleWifi() }
            QuickToggle {
                glyph: ""; text: "Bluetooth"
                on: root.adapter?.enabled ?? false
                onClicked: if (root.adapter) root.adapter.enabled = !root.adapter.enabled
            }
            QuickToggle { glyph: ""; text: "Airplane Mode"; on: Sys.airplane; onClicked: Sys.toggleAirplane() }
            QuickToggle { glyph: ""; text: "Do Not Disturb"; on: Notifs.dnd; onClicked: Notifs.dnd = !Notifs.dnd }
            QuickToggle { glyph: ""; text: "Idle Inhibit"; on: Sys.inhibit; onClicked: Sys.inhibit = !Sys.inhibit }
            QuickToggle {
                glyph: ""; text: "Power Saver"
                on: PowerProfiles.profile === PowerProfile.PowerSaver
                onClicked: PowerProfiles.profile = on ? PowerProfile.Balanced : PowerProfile.PowerSaver
            }
        }
    }

    // ---- volume ----
    Card {
        title: "Volume"; glyph: ""
        RowLayout {
            spacing: 10
            Txt {
                text: Sys.sink?.muted ? "" : ""
                font.pixelSize: 16
                MouseArea { anchors { fill: parent; margins: -4 } onClicked: if (Sys.sink) Sys.sink.muted = !Sys.sink.muted }
            }
            Slide { value: Sys.sink?.volume ?? 0; onMoved: v => Sys.setVol(Sys.sink, v) }
            Txt { text: Math.round((Sys.sink?.volume ?? 0) * 100) + "%"; Layout.preferredWidth: 38; font.pixelSize: 11 }
        }
        Txt {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: Pipewire.defaultAudioSink?.description ?? ""
            color: Theme.muted
            font.pixelSize: 11
        }
    }

    // ---- now playing ----
    Card {
        title: "Now Playing"; glyph: ""
        Txt { visible: !root.player; text: "Nothing playing"; color: Theme.muted }
        RowLayout {
            visible: !!root.player
            spacing: 10
            IconImage {
                implicitSize: 46
                source: root.player?.trackArtUrl ?? ""
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                Txt { Layout.fillWidth: true; text: root.player?.trackTitle ?? ""; font.bold: true }
                Txt { Layout.fillWidth: true; text: root.player?.trackArtist ?? ""; color: Theme.muted; font.pixelSize: 11 }
            }
            Txt { text: ""; font.pixelSize: 15; MouseArea { anchors { fill: parent; margins: -6 } onClicked: root.player?.previous() } }
            Rectangle {
                implicitWidth: 36; implicitHeight: 36; radius: 18
                color: Theme.accent
                Txt {
                    anchors.centerIn: parent
                    text: root.player?.isPlaying ? "" : ""
                    color: Theme.bg
                    font.pixelSize: 14
                }
                MouseArea { anchors.fill: parent; onClicked: root.player?.togglePlaying() }
            }
            Txt { text: ""; font.pixelSize: 15; MouseArea { anchors { fill: parent; margins: -6 } onClicked: root.player?.next() } }
        }
        Slide {
            visible: !!root.player && (root.player?.length ?? 0) > 0
            value: (root.player?.length ?? 0) > 0 ? root.player.position / root.player.length : 0
            onMoved: v => { if (root.player?.canSeek) root.player.position = v * root.player.length }
        }
        RowLayout {
            visible: !!root.player && (root.player?.length ?? 0) > 0
            Txt { text: Sys.fmtTime(root.player?.position ?? 0); color: Theme.muted; font.pixelSize: 10 }
            Item { Layout.fillWidth: true }
            Txt { text: Sys.fmtTime(root.player?.length ?? 0); color: Theme.muted; font.pixelSize: 10 }
        }
    }

    // ---- battery + network ----
    RowLayout {
        spacing: 8
        Card {
            Layout.alignment: Qt.AlignTop
            title: "Battery"; glyph: ""
            Txt { text: Math.round((root.bat?.percentage ?? 0) * 100) + "%"; font.bold: true }
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 5; radius: 3
                color: Theme.subtle
                Rectangle { width: parent.width * (root.bat?.percentage ?? 0); height: parent.height; radius: 3; color: Theme.green }
            }
            Txt {
                color: Theme.muted
                font.pixelSize: 11
                text: ["Performance", "Balanced", "Power Saver"][PowerProfiles.profile === PowerProfile.Performance ? 0 : PowerProfiles.profile === PowerProfile.Balanced ? 1 : 2]
            }
        }
        Card {
            Layout.alignment: Qt.AlignTop
            title: "Network"; glyph: ""
            RowLayout {
                Layout.fillWidth: true
                Repeater {
                    model: [{ g: "↑", v: Sys.up }, { g: "↓", v: Sys.down }]
                    ColumnLayout {
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 0
                        Txt { Layout.alignment: Qt.AlignHCenter; text: modelData.g; color: Theme.muted }
                        Txt { Layout.alignment: Qt.AlignHCenter; text: Sys.fmtRate(modelData.v)[0]; font.bold: true }
                        Txt { Layout.alignment: Qt.AlignHCenter; text: Sys.fmtRate(modelData.v)[1]; color: Theme.muted; font.pixelSize: 10 }
                    }
                }
            }
        }
    }

    // ---- system ----
    Card {
        title: "System"; glyph: ""
        RowLayout {
            Layout.fillWidth: true
            Gauge { Layout.fillWidth: true; value: Sys.cpu / 100; text: Math.round(Sys.cpu) + "%"; caption: "CPU" }
            Gauge { Layout.fillWidth: true; value: Sys.ram / 100; text: Sys.ram + "%"; caption: "RAM" }
            Gauge { Layout.fillWidth: true; value: Sys.disk / 100; text: Sys.disk + "%"; caption: "Disk" }
            Gauge {
                Layout.fillWidth: true
                value: Sys.temp / 100
                text: Math.round(Sys.temp) + "°"
                caption: "CPU Temp"
                color: Sys.temp > 85 ? Theme.red : Theme.accent
            }
        }
    }

    // ---- session ----
    Card {
        RowLayout {
            spacing: 8
            Rectangle {
                implicitWidth: 34; implicitHeight: 34; radius: 10
                color: Theme.subtle
                Txt { anchors.centerIn: parent; text: "" }
            }
            Txt { Layout.fillWidth: true; text: Quickshell.env("USER"); font.bold: true }
            Repeater {
                model: [
                    { g: "", run: () => { Sys.run("hyprlock"); root.close() }, hot: false },
                    { g: "", run: () => Sys.logout(), hot: false },
                    { g: "", run: () => Sys.run("systemctl", "reboot"), hot: false },
                    { g: "", run: () => Sys.run("systemctl", "poweroff"), hot: true }
                ]
                Rectangle {
                    required property var modelData
                    implicitWidth: 34; implicitHeight: 34; radius: 10
                    color: modelData.hot ? Theme.red : Theme.subtle
                    opacity: bm.containsMouse ? 0.85 : 1
                    Txt { anchors.centerIn: parent; text: modelData.g; color: modelData.hot ? Theme.bg : Theme.fg }
                    MouseArea { id: bm; anchors.fill: parent; hoverEnabled: true; onClicked: modelData.run() }
                }
            }
        }
    }
}
