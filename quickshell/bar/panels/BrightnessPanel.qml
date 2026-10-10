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
    Txt { text: "Brightness"; font.bold: true }
    RowLayout {
        spacing: 10
        Txt { text: ""; font.pixelSize: 18; color: Theme.yellow }
        Slide { value: Sys.bright / 100; color: Theme.yellow; onMoved: v => Sys.setBright(v * 100) }
        Txt { text: Sys.bright + "%"; Layout.preferredWidth: 38 }
    }
}
