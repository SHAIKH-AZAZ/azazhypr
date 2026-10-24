import QtQuick
import "../../services"
import "../../theme"
import ".."

// Now playing as one card: the artwork, blurred, fills it, with the artwork,
// title and live lyrics on top and the seek bar, transport controls and
// output volume along the bottom.
Item {
    id: root

    readonly property bool hasPlayer: Media.player !== null
    readonly property string nextLyric: Lyrics.currentIndex + 1 < Lyrics.lines.length
        ? Lyrics.lines[Lyrics.currentIndex + 1].text : ""

    // The artwork or title takes you to the player, closing the island.
    function raisePlayer() {
        Media.raise();
        IslandState.closeRequested();
    }

    // Secondary text and icons over the artwork.
    readonly property color dim: Qt.rgba(1, 1, 1, 0.72)
    readonly property color track: Qt.rgba(1, 1, 1, 0.25)

    // Empty state
    Column {
        anchors.centerIn: parent
        spacing: 10
        visible: !root.hasPlayer

        Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: "music"
            size: 30
            color: Theme.textTertiary
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Nothing playing"
            color: Theme.textSecondary
            font.weight: Font.Medium
        }
    }

    Item {
        anchors.fill: parent
        visible: root.hasPlayer

        RoundedImage {
            anchors.fill: parent
            radius: Theme.cardRadius
            placeholder: ""
            blur: 0.7
            source: Media.art
        }

        // Darkens the artwork at the top and bottom, where the text sits.
        Rectangle {
            anchors.fill: parent
            radius: Theme.cardRadius
            border.color: Theme.border
            border.width: 1
            gradient: Gradient {
                GradientStop { position: 0; color: Qt.rgba(0, 0, 0, 0.62) }
                GradientStop { position: 0.45; color: Qt.rgba(0, 0, 0, 0.3) }
                GradientStop { position: 1; color: Qt.rgba(0, 0, 0, 0.88) }
            }
        }

        RoundedImage {
            id: art
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.top: parent.top
            anchors.topMargin: 14
            width: 56
            height: 56
            radius: 12
            source: Media.art

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.raisePlayer()
            }
        }

        Column {
            anchors.left: art.right
            anchors.leftMargin: 12
            anchors.right: sourceLabel.left
            anchors.rightMargin: 12
            anchors.top: art.top
            anchors.topMargin: 4
            spacing: 2

            Label {
                width: Math.min(implicitWidth, parent.width)
                text: Media.title
                font.pixelSize: Theme.fontTitle
                font.weight: Font.DemiBold
                font.underline: titleMouse.containsMouse
                elide: Text.ElideRight

                MouseArea {
                    id: titleMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.raisePlayer()
                }
            }
            Label {
                width: parent.width
                text: Media.artist || Media.source
                color: root.dim
                font.pixelSize: Theme.fontSmall + 1
                elide: Text.ElideRight
            }
            Item {
                width: 1
                height: 6
            }
            Label {
                id: lyric
                width: parent.width
                visible: Settings.showLyrics && text !== ""
                text: Lyrics.currentText
                font.pixelSize: Theme.fontBody
                font.weight: Font.Medium
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight

                // Each new line blurs and fades in.
                property real blur: 0
                layer.enabled: blur > 0.01
                layer.effect: BlurEffect { amount: lyric.blur }

                onTextChanged: lyricIn.restart()
                ParallelAnimation {
                    id: lyricIn
                    NumberAnimation {
                        target: lyric
                        property: "opacity"
                        from: 0.2
                        to: 1
                        duration: 320
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Theme.smoothCurve
                    }
                    NumberAnimation {
                        target: lyric
                        property: "blur"
                        from: Theme.swapBlur
                        to: 0
                        duration: Theme.swapDuration
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Theme.smoothCurve
                    }
                }
            }
            Label {
                width: parent.width
                visible: lyric.visible && text !== ""
                text: root.nextLyric
                color: Qt.rgba(1, 1, 1, 0.5)
                font.pixelSize: Theme.fontSmall
                elide: Text.ElideRight
            }
        }

        Label {
            id: sourceLabel
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.top: parent.top
            anchors.topMargin: 17
            width: Math.min(implicitWidth, 120)
            text: Media.source
            color: root.dim
            font.pixelSize: Theme.fontCaption + 1
            font.weight: Font.Medium
            elide: Text.ElideRight
        }

        Item {
            id: progressRow
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.bottom: controls.top
            anchors.bottomMargin: 2
            height: 16

            Label {
                id: elapsed
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 42
                text: Timers.formatTime(Media.position * 1000, false)
                color: root.dim
                font.pixelSize: Theme.fontCaption + 1
            }
            Label {
                id: remaining
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 42
                horizontalAlignment: Text.AlignRight
                text: Media.length > 0 ? "-" + Timers.formatTime((Media.length - Media.position) * 1000, false) : ""
                color: root.dim
                font.pixelSize: Theme.fontCaption + 1
            }
            IslandBar {
                id: seekBar
                anchors.left: elapsed.right
                anchors.right: remaining.left
                anchors.verticalCenter: parent.verticalCenter
                implicitHeight: seekArea.containsMouse ? 6 : 4
                color: root.track
                value: Media.progress
            }
            // The playhead, moving with the bar's fill.
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                visible: Media.canSeek && Media.length > 0
                x: seekBar.x + seekBar.width * Math.max(0, Math.min(1, Media.progress)) - width / 2
                width: 12
                height: 12
                radius: 6
                color: Theme.text
                scale: seekArea.containsMouse ? 1.2 : 1
                Behavior on x { NumberAnimation { duration: 260; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.smoothCurve } }
                Behavior on scale { NumberAnimation { duration: Theme.fadeDuration } }
            }
            MouseArea {
                id: seekArea
                anchors.left: elapsed.right
                anchors.right: remaining.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPressed: mouse => Media.seek(mouse.x / width)
                onPositionChanged: mouse => {
                    if (pressed)
                        Media.seek(mouse.x / width);
                }
            }
        }

        Item {
            id: controls
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            height: 36

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                IslandButton {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Media.canSeek
                    icon: "rewind"
                    iconSize: 16
                    color: root.dim
                    onClicked: Media.seekBy(-10)
                }
                IslandButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "previous"
                    iconSize: 20
                    onClicked: Media.previous()
                }
                IslandButton {
                    anchors.verticalCenter: parent.verticalCenter
                    primary: true
                    icon: Media.playing ? "pause" : "play"
                    iconSize: 20
                    onClicked: Media.toggle()
                }
                IslandButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "next"
                    iconSize: 20
                    onClicked: Media.next()
                }
                IslandButton {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Media.canSeek
                    icon: "forward"
                    iconSize: 16
                    color: root.dim
                    onClicked: Media.seekBy(10)
                }

                // Output volume: the icon mutes, the bar (or the wheel) sets the level.
                IslandButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: Audio.muted ? "volumeOff" : "volume"
                    iconSize: 15
                    color: root.dim
                    onClicked: Audio.toggleMute()
                }
                IslandBar {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 64
                    implicitHeight: volumeArea.containsMouse ? 6 : 4
                    color: root.track
                    value: Audio.muted ? 0 : Audio.volume

                    MouseArea {
                        id: volumeArea
                        anchors.fill: parent
                        anchors.margins: -8
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: mouse => Audio.setVolume((mouse.x - 8) / (width - 16))
                        onPositionChanged: mouse => {
                            if (pressed)
                                Audio.setVolume((mouse.x - 8) / (width - 16));
                        }
                        onWheel: wheel => Audio.setVolume(Audio.volume + wheel.angleDelta.y / 120 * 0.05)
                    }
                }
            }

            // Shuffle and repeat show only for players that offer them.
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                IslandButton {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Media.shuffleSupported
                    icon: "shuffle"
                    iconSize: 16
                    color: Media.shuffle ? Theme.accent : root.dim
                    onClicked: Media.toggleShuffle()
                }
                IslandButton {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Media.loopSupported
                    icon: Media.loopingTrack ? "repeatOne" : "repeat"
                    iconSize: 16
                    color: Media.looping ? Theme.accent : root.dim
                    onClicked: Media.cycleLoop()
                }
            }
        }
    }
}
