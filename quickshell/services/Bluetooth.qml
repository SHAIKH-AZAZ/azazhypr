pragma Singleton

import QtQuick
import Quickshell.Bluetooth

// Bluetooth devices known to the default adapter, and its power switch.
// While a device list is open the adapter looks for nearby devices; picking
// a new one pairs it, trusts it and connects. Connect alerts live in Hud.
QtObject {
    id: root

    readonly property var devices: Bluetooth.devices.values
    readonly property var connected: devices.filter(device => device.connected)

    // Connected first, then paired, then nearby devices that have a name.
    readonly property var listed: devices.filter(device => device.paired || device.deviceName !== "")
        .sort((a, b) => (b.connected * 2 + b.paired) - (a.connected * 2 + a.paired))

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: available && adapter.enabled
    readonly property bool discovering: enabled && adapter.discovering

    property int watchers: 0
    // A device being paired, connected once pairing succeeds.
    property var pairingDevice: null

    function toggle() {
        if (!available)
            return;
        const on = !adapter.enabled;
        adapter.enabled = on;
        Activities.show("bluetoothPower", 70, { label: on ? "Bluetooth on" : "Bluetooth off", value: -1, off: !on }, 1800);
    }

    function watch() {
        watchers++;
        discover();
    }

    function unwatch() {
        watchers = Math.max(0, watchers - 1);
        discover();
    }

    function discover() {
        if (enabled)
            adapter.discovering = watchers > 0;
    }

    onEnabledChanged: discover()

    function busy(device) {
        return device.pairing || device.state === BluetoothDeviceState.Connecting
            || device.state === BluetoothDeviceState.Disconnecting;
    }

    function choose(device) {
        if (device.connected || busy(device))
            return;
        device.trusted = true;  // so it reconnects on its own later
        if (device.paired) {
            device.connect();
        } else {
            pairingDevice = device;
            device.pair();
        }
    }

    property Connections pairWatch: Connections {
        target: root.pairingDevice
        ignoreUnknownSignals: true

        function onPairedChanged() {
            if (!root.pairingDevice.paired)
                return;
            root.pairingDevice.connect();
            root.pairingDevice = null;
        }
        function onPairingChanged() {
            if (!root.pairingDevice.pairing && !root.pairingDevice.paired)
                root.pairingDevice = null;  // failed or cancelled
        }
    }
}
