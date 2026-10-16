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

    spacing: 8
    Txt { text: "Output"; font.bold: true }
    RowLayout {
        spacing: 10
        Txt {
            icon: true
            text: Sys.sink?.muted ? "volume_off" : "volume_up"
            font.pixelSize: 18
            MouseArea { anchors { fill: parent; margins: -4 } onClicked: if (Sys.sink) Sys.sink.muted = !Sys.sink.muted }
        }
        Slide { value: Sys.sink?.volume ?? 0; color: Theme.green; onMoved: v => Sys.setVol(Sys.sink, v) }
        Txt { text: Math.round((Sys.sink?.volume ?? 0) * 100) + "%"; Layout.preferredWidth: 38 }
    }
    Txt { text: "Input"; font.bold: true }
    RowLayout {
        spacing: 10
        Txt {
            icon: true
            text: Sys.source?.muted ? "mic_off" : "mic"
            font.pixelSize: 18
            MouseArea { anchors { fill: parent; margins: -4 } onClicked: if (Sys.source) Sys.source.muted = !Sys.source.muted }
        }
        Slide { value: Sys.source?.volume ?? 0; color: Theme.red; onMoved: v => Sys.setVol(Sys.source, v) }
        Txt { text: Math.round((Sys.source?.volume ?? 0) * 100) + "%"; Layout.preferredWidth: 38 }
    }
    Txt { text: "Devices"; font.bold: true }
    Repeater {
        model: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream)
        ListRow {
            required property var modelData
            text: modelData.description || modelData.nickname || modelData.name
            on: modelData === Pipewire.defaultAudioSink
            onClicked: Pipewire.preferredDefaultAudioSink = modelData
        }
    }
}
