import QtQuick
import Quickshell.Services.UPower
import "../components"
import "../services"

// Battery. Charging = breathing bolt, full on AC = plug, low (< 15%) = red blink.
Btn {
    property var bar
    readonly property var dev: UPower.displayDevice
    readonly property real pct: dev?.percentage ?? 0
    readonly property bool charging: dev?.state === UPowerDeviceState.Charging
    readonly property bool full: dev?.state === UPowerDeviceState.FullyCharged
    readonly property bool low: !charging && !full && pct < 0.15

    glyph: charging ? "battery_charging_full" : full ? "power" : low ? "battery_alert" : pct > 0.93 ? "battery_full" : "battery_" + Math.max(1, Math.round(pct * 6)) + "_bar"
    color: charging || full ? Theme.green : pct < 0.15 ? Theme.red : pct < 0.4 ? Theme.yellow : Theme.green
    label: Math.round(pct * 100) + "%"
    pulse: charging
    blink: low
    pop: charging || full      // bounces when the charger is plugged / unplugged
    onClicked: item => bar.toggle("battery", item)
}
