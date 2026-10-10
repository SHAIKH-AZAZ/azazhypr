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

    spacing: 10
    readonly property var p: Sys.player
    Txt { visible: !parent.p; text: "Nothing playing"; color: Theme.muted }
    RowLayout {
        visible: !!parent.p
        spacing: 12
        IconImage {
            implicitSize: 72
            source: p?.trackArtUrl ?? ""
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Txt { Layout.fillWidth: true; text: p?.trackTitle ?? ""; font.bold: true }
            Txt { Layout.fillWidth: true; text: p?.trackArtist ?? ""; color: Theme.muted }
            Txt { Layout.fillWidth: true; text: p?.identity ?? ""; color: Theme.muted; font.pixelSize: 11 }
        }
    }
    RowLayout {
        visible: !!parent.p
        spacing: 8
        Chip { glyph: ""; text: "Prev"; onClicked: p?.previous() }
        Chip { glyph: p?.isPlaying ? "" : ""; text: p?.isPlaying ? "Pause" : "Play"; on: true; onClicked: p?.togglePlaying() }
        Chip { glyph: ""; text: "Next"; onClicked: p?.next() }
    }
}
