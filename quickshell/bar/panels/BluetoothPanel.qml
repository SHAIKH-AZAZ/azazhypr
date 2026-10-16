import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import "../components"
import "../services"

ColumnLayout {
    signal close()

    id: b
    spacing: 8
    readonly property var ad: Bluetooth.defaultAdapter
    readonly property bool on: ad?.enabled ?? false
    readonly property var devs: Bluetooth.devices.values
        .filter(x => x.name && !/^([0-9a-f]{2}[-:]){5}[0-9a-f]{2}$/i.test(x.name))
    readonly property var connected: devs.filter(x => x.connected || x.state === 2)
    readonly property var paired: devs.filter(x => x.paired && !connected.includes(x))
    readonly property var nearby: devs.filter(x => !x.paired && !x.connected)

    // scan while the panel is open
    Component.onCompleted: if (ad?.enabled) ad.discovering = true
    Component.onDestruction: if (ad) ad.discovering = false

    RowLayout {
        spacing: 10
        Txt { icon: true; text: "bluetooth"; font.pixelSize: 20; color: b.on ? Theme.accent : Theme.muted }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Txt { Layout.fillWidth: true; text: "Bluetooth"; font.bold: true }
            Txt {
                Layout.fillWidth: true
                color: Theme.muted
                font.pixelSize: 11
                text: !b.ad ? "No adapter"
                    : !b.on ? "Off"
                    : b.ad.discovering ? "Scanning\u2026"
                    : b.connected.length + " connected"
            }
        }
        Rectangle {
            visible: !!b.ad
            implicitWidth: 40; implicitHeight: 22; radius: 11
            color: b.on ? Theme.accent : Theme.subtle
            Rectangle {
                width: 16; height: 16; radius: 8
                y: 3; x: b.on ? parent.width - width - 3 : 3
                color: b.on ? Theme.bg : Theme.fg
                Behavior on x { NumberAnimation { duration: 120 } }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    b.ad.enabled = !b.on;
                    if (!b.on) b.ad.discovering = false;
                }
            }
        }
    }

    RowLayout {
        visible: b.on
        spacing: 8
        Chip { glyph: "search"; text: b.ad?.discovering ? "Stop scan" : "Scan"; on: b.ad?.discovering ?? false; onClicked: b.ad.discovering = !b.ad.discovering }
        Chip { glyph: "visibility"; text: "Visible"; on: b.ad?.discoverable ?? false; onClicked: b.ad.discoverable = !b.ad.discoverable }
        Chip { glyph: "settings"; text: "Manager"; onClicked: { Sys.run("blueman-manager"); close() } }
    }

    Flickable {
        visible: b.on
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(list.implicitHeight, 300)
        contentHeight: list.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: list
            width: parent.width
            spacing: 2

            Txt { visible: b.connected.length > 0; text: "Connected"; color: Theme.muted; font.pixelSize: 11 }
            Repeater { model: b.connected; BtDevice { required property var modelData; dev: modelData } }

            Txt { visible: b.paired.length > 0; text: "Paired"; color: Theme.muted; font.pixelSize: 11 }
            Repeater { model: b.paired; BtDevice { required property var modelData; dev: modelData } }

            Txt { visible: b.nearby.length > 0; text: "Available"; color: Theme.muted; font.pixelSize: 11 }
            Repeater { model: b.nearby; BtDevice { required property var modelData; dev: modelData } }

            Txt {
                visible: b.devs.length === 0
                text: b.ad?.discovering ? "Searching for devices\u2026" : "No devices. Press Scan."
                color: Theme.muted
            }
        }
    }
}
