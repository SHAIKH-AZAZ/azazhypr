import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "../services"
import "../theme"

// Sound settings, opened from the Overview tab: the output and input devices
// to pick the default from, and the apps playing audio with a volume each.
// Every row's bar sets that device's or app's own volume.
Item {
    id: root

    signal back()

    property string section: "output"     // "output", "input" or "apps"

    readonly property var nodes: Pipewire.nodes.values
    readonly property var outputs: nodes.filter(node => !node.isStream && node.audio && node.type === PwNodeType.AudioSink)
    readonly property var inputs: nodes.filter(node => !node.isStream && node.audio && node.type === PwNodeType.AudioSource)
    readonly property var apps: nodes.filter(node => node.isStream && node.audio && node.type === PwNodeType.AudioOutStream)
    readonly property var shown: section === "output" ? outputs : section === "input" ? inputs : apps

    // Volumes are only valid on bound nodes.
    PwObjectTracker {
        objects: root.outputs.concat(root.inputs, root.apps)
    }

    function deviceKind(node) {
        const name = node.name || "";
        return name.startsWith("bluez") ? "Bluetooth"
            : name.includes("usb") ? "USB"
            : name.includes("hdmi") ? "HDMI"
            : "Built-in";
    }

    function appName(node) {
        return node.properties["application.name"] || node.description || node.name;
    }

    // Header: back, title and the section switch.
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
            text: "Sound"
            font.pixelSize: Theme.fontBody + 1
            font.weight: Font.DemiBold
        }

        Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: sections.width + 6
            height: 26
            radius: 13
            color: Theme.surface

            Row {
                id: sections
                anchors.centerIn: parent

                Repeater {
                    model: [
                        { key: "output", label: "Output" },
                        { key: "input", label: "Input" },
                        { key: "apps", label: "Apps" }
                    ]

                    Rectangle {
                        required property var modelData
                        readonly property bool active: root.section === modelData.key

                        width: sectionLabel.implicitWidth + 22
                        height: 20
                        radius: 10
                        color: active ? Theme.surfaceRaised : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.fadeDuration } }

                        Label {
                            id: sectionLabel
                            anchors.centerIn: parent
                            text: parent.modelData.label
                            color: parent.active ? Theme.text : Theme.textSecondary
                            font.pixelSize: Theme.fontCaption + 1
                            font.weight: Font.DemiBold
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.section = parent.modelData.key
                        }
                    }
                }
            }
        }
    }

    Label {
        anchors.centerIn: list
        visible: root.shown.length === 0
        text: root.section === "apps" ? "No apps are playing sound"
            : root.section === "input" ? "No microphones" : "No speakers or headphones"
        color: Theme.textSecondary
    }

    // A node's own volume: click or drag to set it, or use the wheel.
    component VolumeBar: IslandBar {
        id: bar

        property var node: null

        implicitHeight: barMouse.containsMouse ? 6 : 4
        value: node && node.audio && !node.audio.muted ? Math.min(1, node.audio.volume) : 0
        fillColor: Theme.accent

        function set(fraction) {
            if (node && node.audio)
                node.audio.volume = Math.max(0, Math.min(1, fraction));
        }

        MouseArea {
            id: barMouse
            anchors.fill: parent
            anchors.margins: -8
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onPressed: mouse => bar.set((mouse.x - 8) / (width - 16))
            onPositionChanged: mouse => {
                if (pressed)
                    bar.set((mouse.x - 8) / (width - 16));
            }
            onWheel: wheel => {
                if (bar.node && bar.node.audio)
                    bar.set(bar.node.audio.volume + wheel.angleDelta.y / 120 * 0.05);
            }
        }
    }

    ListView {
        id: list
        anchors.top: header.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true
        spacing: 2
        model: root.shown
        boundsBehavior: Flickable.StopAtBounds

        delegate: Rectangle {
            id: row

            required property var modelData
            readonly property bool isApp: root.section === "apps"
            readonly property bool isDefault: !isApp && (modelData === (root.section === "output"
                ? Pipewire.defaultAudioSink : Pipewire.defaultAudioSource))
            readonly property string iconPath: isApp
                ? Quickshell.iconPath(modelData.properties["application.icon-name"] || "", true) : ""

            width: ListView.view.width
            height: 40
            radius: 10
            color: rowMouse.containsMouse && !isApp ? Theme.surface : "transparent"
            Behavior on color { ColorAnimation { duration: Theme.fadeDuration } }

            // Picks the default device; app rows only hold their controls.
            MouseArea {
                id: rowMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: !row.isApp
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.section === "output")
                        Pipewire.preferredDefaultAudioSink = row.modelData;
                    else
                        Pipewire.preferredDefaultAudioSource = row.modelData;
                }
            }

            Rectangle {
                id: badge
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: 28
                radius: 9
                color: row.isDefault ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.18) : Theme.surfaceRaised

                Image {
                    anchors.centerIn: parent
                    visible: row.iconPath !== ""
                    width: 20
                    height: 20
                    sourceSize.width: 40
                    sourceSize.height: 40
                    source: row.iconPath
                }
                Icon {
                    anchors.centerIn: parent
                    visible: row.iconPath === ""
                    name: row.isApp ? "music"
                        : root.section === "input" ? "mic"
                        : root.deviceKind(row.modelData) === "Bluetooth" ? "bluetooth" : "volume"
                    size: 14
                    color: row.isDefault ? Theme.accent : Theme.textSecondary
                }
            }

            Column {
                anchors.left: badge.right
                anchors.leftMargin: 10
                anchors.right: controls.left
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Label {
                    width: parent.width
                    text: row.isApp ? root.appName(row.modelData) : (row.modelData.description || row.modelData.name)
                    color: row.isDefault ? Theme.text : Theme.textSecondary
                    font.pixelSize: Theme.fontSmall + 1
                    font.weight: row.isDefault || row.isApp ? Font.DemiBold : Font.Medium
                    elide: Text.ElideRight
                }
                Label {
                    width: parent.width
                    text: row.isApp ? (row.modelData.properties["media.name"] || "") : root.deviceKind(row.modelData)
                    visible: text !== ""
                    color: Theme.textTertiary
                    font.pixelSize: Theme.fontCaption
                    elide: Text.ElideRight
                }
            }

            // Mute, volume and, for devices, the default check.
            Row {
                id: controls
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                IslandButton {
                    anchors.verticalCenter: parent.verticalCenter
                    readonly property bool muted: !!(row.modelData.audio && row.modelData.audio.muted)
                    icon: root.section === "input" ? (muted ? "micOff" : "mic") : (muted ? "volumeOff" : "volume")
                    iconSize: 13
                    color: muted ? Theme.red : Theme.textSecondary
                    onClicked: if (row.modelData.audio) row.modelData.audio.muted = !row.modelData.audio.muted
                }
                VolumeBar {
                    anchors.verticalCenter: parent.verticalCenter
                    width: row.isApp ? 150 : 110
                    node: row.modelData
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 32
                    horizontalAlignment: Text.AlignRight
                    text: row.modelData.audio ? Math.round(row.modelData.audio.volume * 100) + "%" : ""
                    color: Theme.textSecondary
                    font.pixelSize: Theme.fontCaption + 1
                }
                Item {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !row.isApp
                    width: 14
                    height: 14

                    Icon {
                        anchors.centerIn: parent
                        visible: row.isDefault
                        name: "check"
                        size: 14
                        color: Theme.accent
                    }
                }
            }
        }
    }
}
