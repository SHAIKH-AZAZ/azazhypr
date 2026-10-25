import QtQuick
import Quickshell
import "../services"
import "../theme"

// The island's notification banner. Clicking runs the app's default action,
// or opens the Notifications tab when there is none. The cross dismisses it,
// and so does a sideways swipe: dragged with the mouse or with two fingers on
// a touchpad. IslandWindow pauses its timer while the pointer is over it.
Item {
    id: root

    signal openRequested()

    // The queued notification, even when another alert outranks it (in
    // fullscreen only notifications show, so it can be on screen anyway).
    readonly property var shown: {
        const entry = Activities.find("notification");
        return entry ? entry.data.notification : null;
    }

    // Keep the last notification on screen while the banner fades out.
    property var notification: null
    onShownChanged: {
        if (!shown)
            return;
        // A new notification replacing one already on screen blurs in.
        if (notification && visible && notification !== shown)
            swapIn.restart();
        notification = shown;
        swipe = 0;
    }
    onVisibleChanged: if (!visible) swipe = 0

    // Sideways offset while swiped. Let go past a third of the width and the
    // banner flies out and is dismissed; short of that it springs back.
    property real swipe: 0

    function settle() {
        if (Math.abs(swipe) > width / 3) {
            flyOut.to = swipe > 0 ? width : -width;
            flyOut.restart();
        } else {
            springBack.restart();
        }
    }

    NumberAnimation {
        id: flyOut
        target: root
        property: "swipe"
        duration: 180
        easing.type: Easing.OutCubic
        onFinished: if (root.notification) root.notification.dismiss()
    }
    NumberAnimation {
        id: springBack
        target: root
        property: "swipe"
        to: 0
        duration: 320
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.springCurve
    }

    // A touchpad swipe arrives as horizontal scrolling; settle once it stops.
    Timer {
        id: scrollEnd
        interval: 120
        onTriggered: root.settle()
    }

    // `blur` is animated by IslandWindow as the banner appears and leaves;
    // `swapBlur` by swapIn when one notification replaces another.
    property real blur: 0
    property real swapBlur: 0
    layer.enabled: Math.max(blur, swapBlur) > 0.01
    layer.effect: BlurEffect { amount: Math.max(root.blur, root.swapBlur) }

    NumberAnimation {
        id: swapIn
        target: root
        property: "swapBlur"
        from: Theme.swapBlur
        to: 0
        duration: Theme.swapDuration
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.smoothCurve
    }

    readonly property bool critical: notification ? Notifications.isCritical(notification) : false
    readonly property string preview: Notifications.preview(notification)

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    HoverHandler {
        id: hover
    }

    MouseArea {
        property real startX: 0
        property bool swiping: false

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPressed: mouse => {
            startX = mouse.x;
            swiping = false;
        }
        onPositionChanged: mouse => {
            if (!swiping && Math.abs(mouse.x - startX) > 6) {
                swiping = true;
                flyOut.stop();
                springBack.stop();
            }
            if (swiping)
                root.swipe = mouse.x - startX;
        }
        onReleased: if (swiping) root.settle()
        onWheel: wheel => {
            const dx = wheel.pixelDelta.x !== 0 ? wheel.pixelDelta.x : wheel.angleDelta.x / 4;
            if (dx === 0 || Math.abs(wheel.angleDelta.y) > Math.abs(wheel.angleDelta.x)) {
                wheel.accepted = false;
                return;
            }
            flyOut.stop();
            springBack.stop();
            root.swipe += dx;
            scrollEnd.restart();
        }
        onClicked: {
            if (swiping || !root.notification)
                return;
            if (Notifications.defaultAction(root.notification))
                Notifications.activate(root.notification);
            else
                root.openRequested();
        }
    }

    // Everything visible; slides and fades with the swipe.
    Item {
        id: content
        anchors.fill: parent
        opacity: 1 - Math.min(1, Math.abs(root.swipe) / root.width)
        transform: Translate { x: root.swipe }

        NotificationIcon {
            id: icon
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            width: 44
            height: 44
            radius: 14
            notification: root.notification
            tint: root.critical ? Theme.red : Theme.accent
        }

        Column {
            anchors.left: icon.right
            anchors.leftMargin: 12
            anchors.right: root.preview !== "" ? previewImage.left : closeButton.left
            anchors.rightMargin: root.preview !== "" ? 12 : 6
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Label {
                width: parent.width
                text: root.notification
                    ? (root.notification.appName || "Notification") + "  ·  " + Notifications.age(root.notification, clock.date.getTime())
                    : ""
                color: root.critical ? Theme.red : Theme.textTertiary
                font.pixelSize: Theme.fontCaption
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Label {
                width: parent.width
                text: root.notification ? root.notification.summary : ""
                font.pixelSize: Theme.fontBody
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Label {
                width: parent.width
                visible: text !== ""
                text: root.notification ? Notifications.plainText(root.notification.body) : ""
                color: Theme.textSecondary
                font.pixelSize: Theme.fontSmall + 1
                textFormat: Text.PlainText
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }

        // The picture, 16:10 and cropped to fill, with a hairline edge.
        RoundedImage {
            id: previewImage
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            visible: root.preview !== ""
            width: 84
            height: 52
            radius: 10
            placeholder: "camera"
            source: root.preview

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "transparent"
                border.color: Qt.rgba(1, 1, 1, 0.12)
                border.width: 1
            }
        }

        IslandButton {
            id: closeButton
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            visible: root.preview === ""
            opacity: hover.hovered ? 1 : 0
            icon: "close"
            iconSize: 13
            color: Theme.textSecondary
            onClicked: if (root.notification) root.notification.dismiss()
            Behavior on opacity { NumberAnimation { duration: Theme.fadeDuration } }
        }

        // With a preview, the cross rides its corner on a dark disc.
        Rectangle {
            anchors.horizontalCenter: previewImage.right
            anchors.horizontalCenterOffset: -2
            anchors.verticalCenter: previewImage.top
            anchors.verticalCenterOffset: 2
            visible: root.preview !== ""
            opacity: hover.hovered ? 1 : 0
            width: 20
            height: 20
            radius: 10
            color: Theme.surfaceRaised
            border.color: Theme.island
            border.width: 2
            Behavior on opacity { NumberAnimation { duration: Theme.fadeDuration } }

            Icon {
                anchors.centerIn: parent
                name: "close"
                size: 10
                color: Theme.text
            }
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.notification) root.notification.dismiss()
            }
        }
    }
}
