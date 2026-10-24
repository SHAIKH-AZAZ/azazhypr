import QtQuick
import "../services"
import "../theme"

// Bluetooth devices to pick from, opened from the Overview tab. Paired
// devices connect on click, nearby ones pair first; connected ones offer a
// disconnect. The adapter looks for devices while this list is open.
Item {
    id: root

    signal back()

    Component.onCompleted: Bluetooth.watch()
    Component.onDestruction: Bluetooth.unwatch()

    // Header: back, title, rescan and the power switch.
    Item {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 28

        IslandButton {
            id: backButton
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            icon: "chevronLeft"
            iconSize: 16
            color: Theme.textSecondary
            onClicked: root.back()
        }
        Label {
            anchors.left: backButton.right
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            text: "Bluetooth"
            font.pixelSize: Theme.fontBody + 1
            font.weight: Font.DemiBold
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            IslandButton {
                id: rescanButton
                anchors.verticalCenter: parent.verticalCenter
                visible: Bluetooth.enabled
                icon: "refresh"
                iconSize: 14
                color: Theme.textSecondary
                onClicked: Bluetooth.discover()

                RotationAnimation on rotation {
                    running: Bluetooth.discovering
                    from: 0
                    to: 360
                    duration: 900
                    loops: Animation.Infinite
                    onRunningChanged: if (!running) rescanButton.rotation = 0
                }
            }

            // On/off switch.
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 36
                height: 20
                radius: 10
                opacity: Bluetooth.available ? 1 : 0.35
                color: Bluetooth.enabled ? Theme.blue : Theme.surfaceRaised
                Behavior on color { ColorAnimation { duration: Theme.fadeDuration } }

                Rectangle {
                    x: Bluetooth.enabled ? parent.width - width - 2 : 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16
                    height: 16
                    radius: 8
                    color: Theme.text
                    Behavior on x {
                        NumberAnimation { duration: 260; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.springCurve }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    enabled: Bluetooth.available
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Bluetooth.toggle()
                }
                Accessible.role: Accessible.CheckBox
                Accessible.name: "Bluetooth"
                Accessible.checked: Bluetooth.enabled
            }
        }
    }

    Label {
        anchors.centerIn: list
        visible: !Bluetooth.enabled || Bluetooth.listed.length === 0
        text: !Bluetooth.available ? "No Bluetooth adapter"
            : !Bluetooth.enabled ? "Bluetooth is off"
            : Bluetooth.discovering ? "Looking for devices…"
            : "No devices found"
        color: Theme.textTertiary
    }

    ListView {
        id: list
        anchors.top: header.bottom
        anchors.topMargin: 6
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: Bluetooth.enabled
        clip: true
        spacing: 2
        boundsBehavior: Flickable.StopAtBounds
        model: Bluetooth.listed

        delegate: Item {
            id: row

            required property var modelData
            readonly property bool busy: Bluetooth.busy(modelData)

            width: ListView.view.width
            height: 32

            Rectangle {
                anchors.fill: parent
                radius: 10
                color: rowHover.hovered ? Theme.surface : "transparent"
                Behavior on color { ColorAnimation { duration: Theme.fadeDuration } }
            }
            HoverHandler {
                id: rowHover
            }
            MouseArea {
                anchors.fill: parent
                enabled: Bluetooth.canChoose(row.modelData)
                cursorShape: Qt.PointingHandCursor
                onClicked: Bluetooth.choose(row.modelData)
            }

            Icon {
                id: deviceIcon
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                name: "bluetooth"
                size: 15
                color: row.modelData.connected ? Theme.blue : Theme.text
            }

            Label {
                anchors.left: deviceIcon.right
                anchors.leftMargin: 10
                anchors.right: trailing.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: row.modelData.name || row.modelData.deviceName
                color: row.modelData.connected ? Theme.blue : Theme.text
                font.pixelSize: Theme.fontSmall + 1
                font.weight: row.modelData.connected ? Font.DemiBold : Font.Medium
                elide: Text.ElideRight
            }

            // Right side: state and actions.
            Row {
                id: trailing
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                height: 24
                spacing: 6

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: text !== ""
                    text: row.modelData.pairing ? "Pairing…"
                        : row.busy ? (row.modelData.connected ? "Disconnecting…" : "Connecting…")
                        : row.modelData.connected && row.modelData.batteryAvailable ? Math.round(row.modelData.battery * 100) + "%"
                        : row.modelData.connected ? "Connected"
                        : row.modelData.paired ? "Paired"
                        : ""
                    color: row.modelData.connected ? Theme.blue : Theme.textTertiary
                    font.pixelSize: Theme.fontCaption + 1
                }
                Spinner {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: row.busy
                    size: 13
                    color: Theme.blue
                }
                IslandButton {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: row.modelData.connected && !row.busy
                    icon: "close"
                    iconSize: 11
                    color: Theme.textSecondary
                    onClicked: row.modelData.disconnect()
                }
            }
        }
    }
}
