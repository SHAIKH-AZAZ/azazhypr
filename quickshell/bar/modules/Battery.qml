import QtQuick
import Quickshell.Services.UPower
import "../components"
import "../services"

Btn {
    property var bar
    readonly property var dev: UPower.displayDevice
    readonly property real pct: dev?.percentage ?? 0
    readonly property bool charging: dev?.state === UPowerDeviceState.Charging

    glyph: charging ? "\uf0e7" : ["\uf244", "\uf243", "\uf242", "\uf241", "\uf240"][Math.min(4, Math.floor(pct * 5))]
    color: charging ? Theme.green : pct < 0.2 ? Theme.red : pct < 0.4 ? Theme.yellow : Theme.green
    label: Math.round(pct * 100) + "%"
    onClicked: item => bar.toggle("battery", item)
}
