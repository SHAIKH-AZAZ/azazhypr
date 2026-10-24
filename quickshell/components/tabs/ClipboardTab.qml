import QtQuick
import "../../services"
import "../../theme"
import ".."

// Clipboard history. The pointer or the arrow keys select an entry; click or
// Enter copies it again, the cross or Delete removes it. A selected image is
// previewed beside the island (ClipboardPreview).
Item {
    id: root

    // Entry that was just copied, shown with a check mark for a moment.
    property string copiedId: ""
    property int selected: 0
    readonly property var selectedItem: Clipboard.items[selected] || null

    onSelectedItemChanged: Clipboard.previewItem = selectedItem && selectedItem.image ? selectedItem : null

    Connections {
        target: Clipboard
        function onItemsChanged() { root.selected = Math.max(0, Math.min(root.selected, Clipboard.items.length - 1)); }
    }

    function select(index) {
        selected = Math.max(0, Math.min(index, Clipboard.items.length - 1));
        list.positionViewAtIndex(selected, ListView.Contain);
    }

    function copy(item) {
        Clipboard.copy(item.id);
        copiedId = item.id;
        copiedReset.restart();
    }

    // The arrows need the keyboard, taken only while the tab is on screen:
    // the island keeps it loaded while collapsed.
    property bool hasKeyboard: false
    function syncKeyboard() {
        if (visible === hasKeyboard)
            return;
        hasKeyboard = visible;
        if (visible) {
            IslandState.takeKeyboard();
            forceActiveFocus();
        } else {
            IslandState.giveKeyboard();
        }
    }
    onVisibleChanged: syncKeyboard()
    Component.onCompleted: syncKeyboard()
    Component.onDestruction: {
        if (hasKeyboard)
            IslandState.giveKeyboard();
        Clipboard.previewItem = null;
    }

    Keys.onUpPressed: select(selected - 1)
    Keys.onDownPressed: select(selected + 1)
    Keys.onReturnPressed: if (selectedItem) copy(selectedItem)
    Keys.onEnterPressed: if (selectedItem) copy(selectedItem)
    Keys.onDeletePressed: if (selectedItem) Clipboard.remove(selectedItem.id)

    Timer {
        id: copiedReset
        interval: 1200
        onTriggered: root.copiedId = ""
    }

    Label {
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: clearButton.verticalCenter
        text: Clipboard.items.length + (Clipboard.items.length === 1 ? " item" : " items")
        color: Theme.textTertiary
        font.pixelSize: Theme.fontSmall
        font.weight: Font.Medium
    }
    IslandButton {
        id: clearButton
        anchors.right: parent.right
        anchors.top: parent.top
        visible: Clipboard.items.length > 0
        text: "Clear all"
        fontSize: Theme.fontSmall
        subtle: true
        onClicked: Clipboard.clear()
    }

    Column {
        anchors.centerIn: list
        spacing: 8
        visible: Clipboard.items.length === 0

        Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: "copy"
            size: 26
            color: Theme.textTertiary
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Settings.clipboardEnabled ? "Copied text and images show up here" : "Clipboard history is off"
            color: Theme.textSecondary
        }
    }

    ListView {
        id: list
        anchors.top: clearButton.bottom
        anchors.topMargin: 6
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true
        spacing: 2
        model: Clipboard.items
        boundsBehavior: Flickable.StopAtBounds

        delegate: Rectangle {
            id: entry

            required property var modelData
            required property int index
            readonly property bool copied: root.copiedId === modelData.id
            readonly property bool isImage: modelData.image !== ""

            width: ListView.view.width
            height: 32
            radius: 10
            color: copied ? Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, 0.14)
                : index === root.selected ? Theme.surface : "transparent"
            Behavior on color { ColorAnimation { duration: Theme.fadeDuration } }

            // Stays hovered over the delete button too, unlike a MouseArea.
            HoverHandler {
                id: rowHover
                onHoveredChanged: {
                    if (hovered)
                        root.selected = entry.index;
                }
            }

            MouseArea {
                id: rowMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.copy(entry.modelData)
            }

            // A thumbnail, or a glyph tile so text lines up with images.
            RoundedImage {
                id: thumb
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                visible: entry.isImage
                width: 34
                height: 22
                radius: 5
                placeholder: "camera"
                source: entry.isImage ? Clipboard.imageUrl(entry.modelData) : ""
            }
            Rectangle {
                anchors.fill: thumb
                visible: !entry.isImage
                radius: 5
                color: Theme.surfaceRaised

                Icon {
                    anchors.centerIn: parent
                    name: "clipboard"
                    size: 12
                    color: Theme.textTertiary
                }
            }

            Label {
                anchors.left: thumb.right
                anchors.leftMargin: 10
                anchors.right: entry.isImage ? sizeLabel.left : trailing.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: entry.isImage ? "Image  " + entry.modelData.width + " × " + entry.modelData.height : entry.modelData.text
                font.pixelSize: Theme.fontBody - 1
                elide: Text.ElideRight
            }
            Label {
                id: sizeLabel
                anchors.right: trailing.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                visible: entry.isImage
                text: entry.isImage ? entry.modelData.size : ""
                color: Theme.textTertiary
                font.pixelSize: Theme.fontCaption + 1
            }

            Item {
                id: trailing
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: 28

                Icon {
                    anchors.centerIn: parent
                    visible: entry.copied
                    name: "check"
                    size: 15
                    color: Theme.green
                }
                IslandButton {
                    anchors.centerIn: parent
                    visible: !entry.copied
                    opacity: rowHover.hovered ? 1 : 0
                    icon: "close"
                    iconSize: 13
                    color: Theme.textSecondary
                    onClicked: Clipboard.remove(entry.modelData.id)
                    Behavior on opacity { NumberAnimation { duration: Theme.fadeDuration } }
                }
            }
        }
    }
}
