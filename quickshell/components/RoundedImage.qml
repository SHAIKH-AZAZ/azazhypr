import QtQuick
import QtQuick.Effects
import "../theme"

// Image clipped to a rounded rectangle, with a placeholder icon until it loads.
Item {
    id: root

    property alias source: image.source
    property real radius: 8
    property string placeholder: "music"
    // 0..1; hides the upscaling when a small picture fills a large area.
    property real blur: 0

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: Theme.surfaceRaised
        visible: image.status !== Image.Ready

        Icon {
            anchors.centerIn: parent
            visible: root.placeholder !== ""
            name: root.placeholder
            size: Math.min(parent.width, parent.height) * 0.45
            color: Theme.textTertiary
        }
    }

    Image {
        id: image
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize.width: width * 2
        sourceSize.height: height * 2
        visible: false
    }

    Rectangle {
        id: mask
        anchors.fill: parent
        radius: root.radius
        visible: false
        layer.enabled: true
    }

    MultiEffect {
        anchors.fill: parent
        source: image
        maskEnabled: true
        maskSource: mask
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
        blurEnabled: root.blur > 0
        blur: root.blur
        blurMax: 64
        autoPaddingEnabled: false
        visible: image.status === Image.Ready
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 300 } }
    }
}
