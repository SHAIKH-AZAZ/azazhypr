import QtQuick
import "../services"
import Quickshell
import Quickshell.Wayland

// Volume / brightness popup, bottom center, click-through.
PanelWindow {
    id: osd

    property string glyph: "volume_up"
    property color tint: Theme.green
    property real value: 0
    property bool ready: false

    function show(g, c, v) {
        if (!ready || Config.island) return;   // the island shows it instead
        glyph = g; tint = c; value = v;
        hide.restart();
    }

    anchors.bottom: true
    margins.bottom: 150
    implicitWidth: 260
    implicitHeight: 48
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region {}
    visible: hide.running
    WlrLayershell.namespace: "quickshell-osd"

    Timer { id: hide; interval: Config.osdTimeout }
    Timer { interval: 2000; running: true; onTriggered: osd.ready = true }   // ignore startup churn

    Connections {
        target: Sys.sink ?? null
        function onVolumeChanged() { osd.show(Sys.sink.muted ? "volume_off" : "volume_up", Theme.green, Sys.sink.volume) }
        function onMutedChanged() { osd.show(Sys.sink.muted ? "volume_off" : "volume_up", Theme.green, Sys.sink.volume) }
    }
    Connections {
        target: Sys
        function onBrightChanged() { osd.show("brightness_high", Theme.yellow, Sys.bright / 100) }
    }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: Qt.alpha(Theme.bg, 0.95)
        border { width: 1; color: Theme.subtle }

        Row {
            anchors.centerIn: parent
            spacing: 12
            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: 22
                text: osd.glyph
                color: osd.tint
                font { family: Theme.iconFont; pixelSize: 20 }
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 150; height: 6; radius: 3
                color: Theme.subtle
                Rectangle { width: parent.width * Sys.clamp(osd.value); height: parent.height; radius: 3; color: osd.tint }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: 36
                text: Math.round(osd.value * 100) + "%"
                color: Theme.fg
                font { family: Theme.font; pixelSize: 12 }
            }
        }
    }
}
