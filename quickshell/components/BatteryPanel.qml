import QtQuick
import Quickshell.Services.UPower
import "../services"
import "../theme"

// Battery details, opened from the Overview tab: the charge and what it is
// doing, power draw, stored energy and health on the left; the power mode
// (power-profiles-daemon) to pick on the right.
Item {
    id: root

    signal back()

    // The laptop battery as UPower sees it, for rate, energy and health.
    readonly property var device: UPower.devices.values.find(d => d.isLaptopBattery) || UPower.displayDevice
    readonly property int state: device ? device.state : UPowerDeviceState.Unknown

    readonly property color tint: Battery.charging || state === UPowerDeviceState.FullyCharged ? Theme.green
        : Battery.percent <= Settings.lowBatteryPercent ? Theme.red
        : Theme.text

    readonly property string status: {
        switch (state) {
        case UPowerDeviceState.FullyCharged:
            return "Fully charged";
        case UPowerDeviceState.Charging:
            return device.timeToFull > 0 ? "Charging, " + duration(device.timeToFull) + " to full" : "Charging";
        case UPowerDeviceState.Discharging:
            return device.timeToEmpty > 0 ? "On battery, " + duration(device.timeToEmpty) + " left" : "On battery";
        case UPowerDeviceState.PendingCharge:
            return "Plugged in, not charging";
        default:
            return Battery.status;
        }
    }

    readonly property var modes: [
        { name: "Saver", detail: "Longer battery life", profile: PowerProfile.PowerSaver },
        { name: "Balanced", detail: "Performance and battery", profile: PowerProfile.Balanced },
        { name: "Performance", detail: "Full speed, more power", profile: PowerProfile.Performance }
    ].filter(mode => mode.profile !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)

    function duration(seconds) {
        const minutes = Math.round(seconds / 60);
        return minutes >= 60 ? Math.floor(minutes / 60) + "h " + minutes % 60 + "m" : minutes + "m";
    }

    // Header: back and title.
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
            text: "Battery"
            font.pixelSize: Theme.fontBody + 1
            font.weight: Font.DemiBold
        }
    }

    // Left: charge, status, bar and figures.
    Item {
        id: details
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.top: header.bottom
        anchors.topMargin: 10
        anchors.bottom: parent.bottom
        width: parent.width * 0.52

        Label {
            id: percent
            anchors.left: parent.left
            anchors.top: parent.top
            text: Battery.available ? Battery.percent + "%" : "--"
            color: root.tint
            font.pixelSize: Theme.fontDisplay
            font.weight: Font.DemiBold
        }
        Label {
            anchors.left: percent.right
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.verticalCenter: percent.verticalCenter
            text: root.status
            color: Theme.textSecondary
            font.pixelSize: Theme.fontSmall + 1
            font.weight: Font.Medium
            elide: Text.ElideRight
        }

        IslandBar {
            id: bar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: percent.bottom
            anchors.topMargin: 8
            implicitHeight: 6
            value: Battery.percent / 100
            fillColor: root.tint
        }

        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: bar.bottom
            anchors.topMargin: 16

            Repeater {
                model: [
                    { label: "Draw", value: root.device ? Math.abs(root.device.changeRate).toFixed(1) + " W" : "--" },
                    { label: "Energy", value: root.device && root.device.energyCapacity > 0
                        ? root.device.energy.toFixed(1) + " / " + root.device.energyCapacity.toFixed(1) + " Wh" : "--" },
                    { label: "Health", value: root.device && root.device.healthSupported
                        ? Math.round(root.device.healthPercentage) + "%" : "--" }
                ]

                Column {
                    required property var modelData
                    required property int index

                    // The energy figure is the widest.
                    width: parent.width * (index === 1 ? 0.42 : 0.29)
                    spacing: 2

                    Label {
                        text: modelData.value
                        font.pixelSize: Theme.fontBody
                        font.weight: Font.DemiBold
                    }
                    Label {
                        text: modelData.label
                        color: Theme.textTertiary
                        font.pixelSize: Theme.fontCaption
                        font.weight: Font.Medium
                    }
                }
            }
        }
    }

    // Right: the power mode.
    Column {
        anchors.left: details.right
        anchors.leftMargin: 24
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.topMargin: 6
        spacing: 4

        Label {
            leftPadding: 10
            text: "Power mode"
            color: Theme.textTertiary
            font.pixelSize: Theme.fontCaption
            font.weight: Font.Medium
        }

        Repeater {
            model: root.modes

            Rectangle {
                id: option

                required property var modelData
                readonly property bool selected: PowerProfiles.profile === modelData.profile

                width: parent.width
                height: 34
                radius: 10
                color: selected ? Theme.surfaceRaised : optionMouse.containsMouse ? Theme.surface : "transparent"
                Behavior on color { ColorAnimation { duration: Theme.fadeDuration } }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.right: check.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        text: option.modelData.name
                        color: option.selected ? Theme.text : Theme.textSecondary
                        font.pixelSize: Theme.fontSmall + 1
                        font.weight: option.selected ? Font.DemiBold : Font.Medium
                    }
                    Label {
                        width: parent.width
                        text: option.modelData.detail
                        color: Theme.textTertiary
                        font.pixelSize: Theme.fontCaption
                        elide: Text.ElideRight
                    }
                }
                Icon {
                    id: check
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    visible: option.selected
                    name: "check"
                    size: 14
                    color: Theme.accent
                }

                MouseArea {
                    id: optionMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PowerProfiles.profile = option.modelData.profile
                }
            }
        }
    }
}
