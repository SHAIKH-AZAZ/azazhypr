import QtQuick
import Quickshell
import "../panels"   // static import so the panel dir is scanned (siblings resolve)
import "../services"

// One popup per bar; `name` picks the panel file in panels/, "" hides it.
// To add a panel: drop panels/FooPanel.qml (root item, optional `signal close()`),
// add it to `files`, call bar.toggle("foo", item) from a module.
PopupWindow {
    id: root

    required property var bar
    property string name: ""
    property real cx: 0

    readonly property var files: ({
        dashboard: "DashboardPanel",
        calendar: "CalendarPanel",
        media: "MediaPanel",
        audio: "AudioPanel",
        bluetooth: "BluetoothPanel",
        network: "NetworkPanel",
        brightness: "BrightnessPanel",
        battery: "BatteryPanel",
        notifications: "NotificationsPanel",
        system: "SystemPanel"
    })
    readonly property var widths: ({ calendar: 420, bluetooth: 360, dashboard: 410, notifications: 390 })
    readonly property int w: widths[name] ?? 320

    anchor.window: bar
    anchor.rect: Qt.rect(Math.max(4, Math.min(bar.width - w - 4, cx - w / 2)), bar.height + 4, 1, 1)
    implicitWidth: w
    implicitHeight: body.implicitHeight + 24
    visible: name !== ""
    color: "transparent"

    function close() { bar.drop = "" }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Theme.bg
        border { width: 1; color: Theme.subtle }

        Loader {
            id: body
            x: 12; y: 12
            width: parent.width - 24
            source: root.files[root.name] ? Qt.resolvedUrl("../panels/" + root.files[root.name] + ".qml") : ""
        }

        Connections {
            target: body.item
            ignoreUnknownSignals: true
            function onClose() { root.close() }
        }
    }
}
