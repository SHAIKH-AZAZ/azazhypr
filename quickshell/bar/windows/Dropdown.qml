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
        system: "SystemPanel",
        activity: "ActivityPanel",
        weather: "WeatherPanel"
    })
    readonly property var widths: ({ calendar: 420, bluetooth: 360, dashboard: 410, notifications: 390, activity: 440, weather: 460, battery: 380 })
    readonly property int w: widths[name] ?? 320

    anchor.window: bar
    anchor.rect: Qt.rect(Math.max(4, Math.min(bar.width - w - 4, cx - w / 2)), bar.height + 4, 1, 1)
    implicitWidth: w
    // never taller than the space below the bar: a popup that does not fit gets shifted/clipped by the
    // compositor (buttons then miss their clicks). Longer content scrolls instead.
    readonly property real maxH: Math.max(240, (bar.screen?.height ?? 1080) - bar.height - 24)
    implicitHeight: Math.min(body.implicitHeight + 24, maxH)
    visible: name !== ""
    color: "transparent"

    function close() { bar.drop = "" }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Theme.bg
        border { width: 1; color: Theme.subtle }

        // scrolls (wheel / drag) when the panel is taller than the popup
        Flickable {
            id: flick
            x: 12; y: 12
            width: parent.width - 24
            height: parent.height - 24
            contentWidth: width
            contentHeight: body.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick

            Loader {
                id: body
                width: flick.width
                source: root.files[root.name] ? Qt.resolvedUrl("../panels/" + root.files[root.name] + ".qml") : ""
                onLoaded: flick.contentY = 0
            }
        }
        // thin scroll indicator
        Rectangle {
            visible: flick.contentHeight > flick.height + 1
            x: parent.width - 7; width: 3; radius: 1.5
            y: 12 + flick.height * (flick.contentY / flick.contentHeight)
            height: Math.max(24, flick.height * flick.height / flick.contentHeight)
            color: Qt.alpha(Theme.fg, 0.35)
        }

        Connections {
            target: body.item
            ignoreUnknownSignals: true
            function onClose() { root.close() }
        }
    }
}
