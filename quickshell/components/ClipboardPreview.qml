import QtQuick
import "../services"
import "../theme"

// A clipboard image shown whole beside the island, with its format, size and
// weight underneath. Display only: the island's input mask leaves it out, so
// clicks go through to the window below.
Rectangle {
    id: root

    // The entry to show, or null; the last one stays while the card fades out.
    property var item: null
    property var shownItem: null
    onItemChanged: if (item) shownItem = item

    readonly property real maxImageWidth: 340
    readonly property real maxImageHeight: 200
    readonly property real aspect: shownItem ? shownItem.width / Math.max(1, shownItem.height) : 16 / 9
    readonly property real imageWidth: Math.min(maxImageWidth, maxImageHeight * aspect)

    width: imageWidth + 24
    height: picture.height + caption.height + 34
    radius: 22
    color: Theme.island
    border.color: Theme.border
    border.width: 1

    opacity: item ? 1 : 0
    scale: item ? 1 : 0.94
    transformOrigin: Item.TopLeft
    visible: opacity > 0.01
    Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.smoothCurve } }
    Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.springCurve } }
    Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.smoothCurve } }
    Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.smoothCurve } }

    RoundedImage {
        id: picture
        x: 12
        y: 12
        width: parent.width - 24
        height: width / root.aspect
        radius: 12
        placeholder: "camera"
        source: root.shownItem ? Clipboard.imageUrl(root.shownItem) : ""

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: Qt.rgba(1, 1, 1, 0.1)
            border.width: 1
        }
    }

    Label {
        id: caption
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.top: picture.bottom
        anchors.topMargin: 9
        text: root.shownItem
            ? root.shownItem.format.toUpperCase() + "  ·  " + root.shownItem.width + " × " + root.shownItem.height + "  ·  " + root.shownItem.size
            : ""
        color: Theme.textSecondary
        font.pixelSize: Theme.fontCaption + 1
        font.weight: Font.Medium
        elide: Text.ElideRight
    }
}
