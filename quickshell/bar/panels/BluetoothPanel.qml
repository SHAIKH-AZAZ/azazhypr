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

    // ---------------- header ----------------
    RowLayout {
        spacing: 10
        Txt { icon: true; text: b.on ? "bluetooth" : "bluetooth_disabled"; font.pixelSize: 20; color: b.on ? Theme.accent : Theme.muted }
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
                    : b.connected.length ? b.connected.length + " connected" : "Not connected"
            }
        }
        Txt {   // scan
            visible: b.on
            icon: true; text: "refresh"; font.pixelSize: 18
            color: b.ad?.discovering || scanMa.containsMouse ? Theme.accent : Theme.fg
            RotationAnimation on rotation { running: b.ad?.discovering ?? false; from: 0; to: 360; duration: 900; loops: Animation.Infinite; alwaysRunToEnd: true }
            MouseArea { id: scanMa; anchors { fill: parent; margins: -6 } hoverEnabled: true; onClicked: b.ad.discovering = !b.ad.discovering }
        }
        Txt {   // discoverable
            visible: b.on
            icon: true; text: b.ad?.discoverable ? "visibility" : "visibility_off"; font.pixelSize: 18
            color: b.ad?.discoverable ? Theme.accent : visMa.containsMouse ? Theme.fg : Theme.muted
            MouseArea { id: visMa; anchors { fill: parent; margins: -6 } hoverEnabled: true; onClicked: b.ad.discoverable = !b.ad.discoverable }
        }
        Txt {
            icon: true; text: "settings"; font.pixelSize: 18
            color: cfgMa.containsMouse ? Theme.accent : Theme.fg
            MouseArea { id: cfgMa; anchors { fill: parent; margins: -6 } hoverEnabled: true; onClicked: { Sys.run("blueman-manager"); b.close() } }
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

    Txt { visible: !b.on; Layout.fillWidth: true; text: b.ad ? "Bluetooth is off" : "No Bluetooth adapter"; color: Theme.muted; horizontalAlignment: Text.AlignHCenter; Layout.topMargin: 12; Layout.bottomMargin: 12 }

    // ---------------- sections: uppercase label + grouped card ----------------
    component Section: ColumnLayout {
        id: sec
        property string title
        property var devs: []
        visible: b.on && devs.length > 0      // from the list, not the card height (hidden children have none)
        Layout.fillWidth: true
        spacing: 6
        Txt { text: sec.title; color: Theme.muted; font { pixelSize: 10; bold: true; letterSpacing: 1 } }
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: col.implicitHeight
            radius: 10
            color: Qt.alpha(Theme.subtle, 0.5)
            clip: true
            Column {
                id: col
                width: parent.width
                Repeater { model: sec.devs; BtDevice { required property var modelData; required property int index; dev: modelData; first: index === 0 } }
            }
        }
    }

    Section { title: "CONNECTED"; devs: b.connected }
    Section { title: "PAIRED DEVICES"; devs: b.paired }
    Section { title: "AVAILABLE DEVICES"; devs: b.nearby }

    Txt {
        visible: b.on && b.devs.length === 0
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: b.ad?.discovering ? "Searching for devices\u2026" : "No devices. Press \u21bb to scan."
        color: Theme.muted
    }
}
