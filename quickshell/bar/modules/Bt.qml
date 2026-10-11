import QtQuick
import Quickshell.Bluetooth
import "../components"
import "../services"

// Bluetooth. Off = struck-out; on = dim; a connected device shows its own icon (headphones,
// keyboard, mouse, ...) with a soft pulse and its battery when it reports one.
Btn {
    property var bar
    readonly property bool on: Bluetooth.defaultAdapter?.enabled ?? false
    readonly property var conn: Bluetooth.devices.values.filter(d => d.connected)
    readonly property var first: conn.length > 0 ? conn[0] : null

    glyph: first ? Sys.btGlyph(first.icon ?? "") : "\uf293"
    color: !on ? Theme.muted : first ? Theme.blue : Qt.alpha(Theme.blue, 0.6)
    struck: !on
    struckColor: Theme.red
    pulse: first !== null
    pop: conn.length                // bounces when a device connects / disconnects
    label: !first ? "" : first.batteryAvailable ? Math.round(first.battery * 100) + "%" : conn.length > 1 ? "+" + (conn.length - 1) : ""
    onClicked: item => bar.toggle("bluetooth", item)
}
