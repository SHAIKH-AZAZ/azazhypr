import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

// Screen share picker with live previews, for xdg-desktop-portal-hyprland's
// `custom_picker_binary`. Launched through ./share-picker, which forwards the
// `[SELECTION]` line logged by finish() to the portal.
ShellRoot {
    id: root

    // Tokens from ../theme/Theme.qml, which Quickshell can't import from outside this config root.
    QtObject {
        id: theme
        readonly property string fontFamily: Qt.application.font.family
        readonly property int fontSmall: 11
        readonly property int fontBody: 13
        readonly property color surface: "#141416"
        readonly property color surfaceRaised: "#26262a"
        readonly property color border: Qt.rgba(1, 1, 1, 0.08)
        readonly property color text: "#f5f5f7"
        readonly property color textSecondary: "#a1a1a6"
        readonly property color accent: "#0a84ff"
        readonly property int padding: 18
        readonly property int cardRadius: 18
    }

    // "<id>[HC>]<class>[HT>]<title>[HE>]<address>[HA>]" per window.
    readonly property var windows: (Quickshell.env("XDPH_WINDOW_SHARING_LIST") ?? "").split("[HA>]").filter(Boolean).map(entry => {
        const [id, afterId] = entry.split("[HC>]");
        const [appClass, afterClass] = afterId.split("[HT>]");
        const [title, address] = afterClass.split("[HE>]");
        return { id, appClass, title, address };
    })

    function finish(selection) {
        console.info(`[SELECTION]${remember.checked ? "r" : ""}/${selection}`);
        Qt.quit();
    }

    function toplevelFor(win) {
        const toplevels = ToplevelManager.toplevels.values;
        const address = Number(win.address).toString(16);
        // The portal escapes some characters in titles, so they only work as a fallback.
        return toplevels.find(t => t.HyprlandToplevel?.address === address)
            ?? toplevels.find(t => t.appId === win.appClass && t.title === win.title)
            ?? null;
    }

    component Card: Rectangle {
        id: card

        property alias source: preview.captureSource
        property string label
        property string iconName
        signal picked

        width: 280
        height: 196
        radius: theme.cardRadius
        color: hover.hovered || activeFocus ? theme.surfaceRaised : "transparent"
        border.width: 2
        border.color: activeFocus ? theme.accent : "transparent"
        activeFocusOnTab: true
        Accessible.role: Accessible.Button
        Accessible.name: label

        onActiveFocusChanged: {
            if (activeFocus)
                scroller.contentY = Math.max(0, Math.min(mapToItem(content, 0, 0).y - theme.padding, scroller.contentHeight - scroller.height));
        }

        Keys.onReturnPressed: picked()
        Keys.onEnterPressed: picked()
        Keys.onSpacePressed: picked()
        Keys.onRightPressed: nextItemInFocusChain(true).forceActiveFocus()
        Keys.onLeftPressed: nextItemInFocusChain(false).forceActiveFocus()

        HoverHandler {
            id: hover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: card.picked()
        }

        Item {
            id: thumbnail
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: caption.top
                margins: 10
            }

            ScreencopyView {
                id: preview
                anchors.centerIn: parent
                width: implicitWidth
                height: implicitHeight
                constraintSize: Qt.size(thumbnail.width, thumbnail.height)
                live: true
            }
        }

        Row {
            id: caption
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 10
            }
            spacing: 8

            Image {
                id: icon
                visible: card.iconName !== ""
                width: 18
                height: 18
                sourceSize: Qt.size(36, 36)
                source: card.iconName === "" ? "" : Quickshell.iconPath(card.iconName, true)
            }

            Text {
                width: parent.width - (icon.visible ? icon.width + parent.spacing : 0)
                text: card.label
                // Titles come from apps and web pages, never parse them as markup.
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: theme.text
                font.family: theme.fontFamily
                font.pixelSize: theme.fontBody
            }
        }
    }

    component Action: Rectangle {
        id: action

        property string label
        signal triggered

        width: labelText.implicitWidth + 28
        height: 34
        radius: height / 2
        color: actionHover.hovered ? theme.surfaceRaised : "transparent"
        border.width: 1
        border.color: activeFocus ? theme.accent : theme.border
        activeFocusOnTab: true
        Accessible.role: Accessible.Button
        Accessible.name: label

        Keys.onReturnPressed: triggered()
        Keys.onEnterPressed: triggered()
        Keys.onSpacePressed: triggered()

        HoverHandler {
            id: actionHover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: action.triggered()
        }

        Text {
            id: labelText
            anchors.centerIn: parent
            text: action.label
            color: theme.text
            font.family: theme.fontFamily
            font.pixelSize: theme.fontSmall
        }
    }

    Process {
        id: slurp
        command: ["slurp", "-f", "%o %x %y %w %h"]
        stdout: StdioCollector {
            onStreamFinished: {
                const [name, x, y, w, h] = text.trim().split(" ");
                const screen = Quickshell.screens.find(s => s.name === name);
                if (screen)
                    root.finish(`region:${name}@${x - screen.x},${y - screen.y},${w},${h}`);
                else
                    window.visible = true; // Selection was cancelled.
            }
        }
    }

    FloatingWindow {
        id: window

        title: "Share your screen"
        implicitWidth: 920
        implicitHeight: 640
        // Equal limits make Hyprland float the window instead of tiling it.
        minimumSize: Qt.size(implicitWidth, implicitHeight)
        maximumSize: Qt.size(implicitWidth, implicitHeight)
        color: theme.surface

        onClosed: Qt.quit()

        Item {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: Qt.quit()

            Flickable {
                id: scroller
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: footer.top
                }
                clip: true
                contentHeight: content.implicitHeight + 2 * theme.padding

                Column {
                    id: content
                    x: theme.padding
                    y: theme.padding
                    width: scroller.width - 2 * theme.padding
                    spacing: 10

                    Text {
                        text: "Screens"
                        color: theme.textSecondary
                        font.family: theme.fontFamily
                        font.pixelSize: theme.fontSmall
                    }

                    Flow {
                        width: parent.width
                        spacing: 10

                        Repeater {
                            model: Quickshell.screens

                            Card {
                                required property var modelData
                                required property int index
                                focus: index === 0
                                source: modelData
                                label: `${modelData.name} · ${modelData.width}×${modelData.height}`
                                onPicked: root.finish(`screen:${modelData.name}`)
                            }
                        }
                    }

                    Text {
                        visible: root.windows.length > 0
                        text: "Windows"
                        color: theme.textSecondary
                        font.family: theme.fontFamily
                        font.pixelSize: theme.fontSmall
                    }

                    Flow {
                        width: parent.width
                        spacing: 10

                        Repeater {
                            model: root.windows

                            Card {
                                required property var modelData
                                source: root.toplevelFor(modelData)
                                label: modelData.title
                                iconName: DesktopEntries.heuristicLookup(modelData.appClass)?.icon ?? modelData.appClass
                                onPicked: root.finish(`window:${modelData.id}`)
                            }
                        }
                    }
                }
            }

            Row {
                id: footer
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    margins: theme.padding
                }
                spacing: 10

                Action {
                    id: remember
                    property bool checked: Quickshell.env("SHARE_PICKER_ALLOW_TOKEN") === "1"
                    label: (checked ? "✓ " : "") + "Remember this choice"
                    Accessible.role: Accessible.CheckBox
                    Accessible.checked: checked
                    onTriggered: checked = !checked
                }

                Action {
                    label: "Select region…"
                    onTriggered: {
                        window.visible = false;
                        slurp.running = true;
                    }
                }

                Action {
                    label: "Cancel"
                    onTriggered: Qt.quit()
                }
            }
        }
    }
}
