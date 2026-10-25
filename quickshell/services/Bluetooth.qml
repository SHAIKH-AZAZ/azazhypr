pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io

// Bluetooth devices known to the default adapter, and its power switch.
// While a device list is open the adapter looks for nearby devices; picking
// a new one pairs it, trusts it and connects. Connect alerts live in Hud.
QtObject {
    id: root

    readonly property var devices: Bluetooth.devices.values
    readonly property var connected: devices.filter(device => device.connected)

    // Connected first, then paired, then nearby devices that have a name; in
    // the order found within each, so new devices join at the bottom instead
    // of moving rows under the pointer.
    readonly property var listed: devices.filter(device => device.paired || device.deviceName !== "")
        .sort((a, b) => (b.connected * 2 + b.paired) - (a.connected * 2 + a.paired) || devices.indexOf(a) - devices.indexOf(b))

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: available && adapter.enabled
    readonly property bool discovering: enabled && adapter.discovering
    // Powered and settled: `enabled` flips before discovery can start.
    readonly property bool ready: available && adapter.state === BluetoothAdapterState.Enabled

    property int watchers: 0

    // Left bud, right bud and case charge of connected earbuds that speak
    // Google Fast Pair, by address: { left, right, case, leftCharging, ... },
    // a level -1 when unknown. Read by scripts/fastpair-battery.py.
    property var buds: ({})

    // The earbud levels as [{ name, value, charging }] for the left bud, right
    // bud and case, leaving out unknown ones; [] for other devices.
    function budsParts(device) {
        const levels = device ? buds[device.address] : undefined;
        if (!levels)
            return [];
        return [
            { name: "L", value: levels.left, charging: levels.leftCharging },
            { name: "R", value: levels.right, charging: levels.rightCharging },
            { name: "Case", value: levels["case"], charging: levels.caseCharging }
        ].filter(part => part.value >= 0);
    }

    // "L99% R99% C98%" for earbuds that report levels, otherwise "".
    function budsBattery(device) {
        return budsParts(device).map(part => part.name[0] + part.value + "%").join(" ");
    }
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
        if (ready)
            adapter.discovering = watchers > 0;
    }

    onReadyChanged: discover()

    function busy(device) {
        return device.pairing || device.state === BluetoothDeviceState.Connecting
            || device.state === BluetoothDeviceState.Disconnecting;
    }

    // One new device at a time, so each still gets its connect once paired.
    function canChoose(device) {
        return !device.connected && !busy(device) && (device.paired || pairingDevice === null);
    }

    function choose(device) {
        if (!canChoose(device))
            return;
        if (device.paired) {
            device.trusted = true;  // so it reconnects on its own later
            device.connect();
        } else {
            pairingDevice = device;
            device.pair();
        }
    }

    property Process budsReader: Process {
        running: root.connected.length > 0
        command: ["python3", "-I", Quickshell.shellDir + "/services/scripts/fastpair-battery.py"]
        stdout: SplitParser {
            onRead: line => {
                const report = JSON.parse(line);
                const next = Object.assign({}, root.buds);
                if (report.left === undefined)
                    delete next[report.address];
                else
                    next[report.address] = report;
                root.buds = next;
            }
        }
        onRunningChanged: {
            if (running)
                return;
            root.buds = {};
            if (root.connected.length > 0)
                budsRetry.restart();
        }
    }

    // The reader stopped while devices are connected (bluetoothd restarted,
    // or another copy still held the profile); start it again.
    // ponytail: retries forever every 30s, add a cap if it ever fails for good.
    property Timer budsRetry: Timer {
        interval: 30000
        onTriggered: root.budsReader.running = Qt.binding(() => root.connected.length > 0)
    }

    property Connections pairWatch: Connections {
        target: root.pairingDevice
        ignoreUnknownSignals: true

        function onPairedChanged() {
            if (!root.pairingDevice.paired)
                return;
            root.pairingDevice.trusted = true;
            root.pairingDevice.connect();
            root.pairingDevice = null;
        }
        function onPairingChanged() {
            if (!root.pairingDevice.pairing && !root.pairingDevice.paired)
                root.pairingDevice = null;  // failed or cancelled
        }
    }
}
