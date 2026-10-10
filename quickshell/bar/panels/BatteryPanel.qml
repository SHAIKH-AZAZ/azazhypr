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
    readonly property var d: UPower.displayDevice
    readonly property bool charging: d?.state === UPowerDeviceState.Charging
    readonly property real secs: charging ? (d?.timeToFull ?? 0) : (d?.timeToEmpty ?? 0)

    Txt { text: Math.round((d?.percentage ?? 0) * 100) + "%  ·  " + (charging ? "Charging" : UPower.onBattery ? "Discharging" : "Plugged in"); font.bold: true }
    Txt {
        visible: b.secs > 0
        color: Theme.muted
        text: Math.floor(b.secs / 3600) + "h " + Math.floor(b.secs % 3600 / 60) + "m " + (b.charging ? "to full" : "remaining")
    }
    Txt { text: "Power profile"; font.bold: true }
    RowLayout {
        spacing: 8
        Chip { glyph: ""; text: "Saver"; on: PowerProfiles.profile === PowerProfile.PowerSaver; onClicked: PowerProfiles.profile = PowerProfile.PowerSaver }
        Chip { glyph: ""; text: "Balanced"; on: PowerProfiles.profile === PowerProfile.Balanced; onClicked: PowerProfiles.profile = PowerProfile.Balanced }
        Chip {
            visible: PowerProfiles.hasPerformanceProfile
            glyph: ""; text: "Perf"
            on: PowerProfiles.profile === PowerProfile.Performance
            onClicked: PowerProfiles.profile = PowerProfile.Performance
        }
    }
}
