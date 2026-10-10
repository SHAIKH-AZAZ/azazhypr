import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import "../components"
import "../services"

// Notification center: header (count, DND, clear), empty state, one card per notification.
// Card click = run the "default" action and dismiss; x = dismiss only; labelled actions are buttons.
ColumnLayout {
    id: root
    signal close()
    spacing: 12

    readonly property int count: Notifs.list.values.length
    property int tick: 0            // bumps every 30s so "5m" labels stay fresh
    Timer { interval: 30000; running: true; repeat: true; onTriggered: root.tick++ }

    function ago(id) {
        void root.tick;
        const t = Notifs.times[id];
        if (!t) return "";
        const s = (Date.now() - t) / 1000;
        if (s < 60) return "now";
        if (s < 3600) return Math.floor(s / 60) + "m ago";
        if (s < 86400) return Math.floor(s / 3600) + "h ago";
        return Math.floor(s / 86400) + "d ago";
    }

    // ---- header ----
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Txt { text: "Notifications"; font { pixelSize: 16; bold: true } }
        Rectangle {
            visible: root.count > 0
            implicitWidth: Math.max(22, badge.implicitWidth + 12)
            implicitHeight: 20
            radius: Config.notifRadius
            color: Theme.accent
            Txt { id: badge; anchors.centerIn: parent; text: root.count; color: Theme.bg; font { pixelSize: 11; bold: true } }
        }
        Item { Layout.fillWidth: true }

        // Do Not Disturb
        Rectangle {
            implicitWidth: dndRow.implicitWidth + 20
            implicitHeight: 28
            radius: Config.notifRadius
            color: Notifs.dnd ? Theme.accent : Qt.alpha(Theme.subtle, dndMa.containsMouse ? 1 : 0.7)
            Row {
                id: dndRow
                anchors.centerIn: parent
                spacing: 6
                Txt { text: ""; color: Notifs.dnd ? Theme.bg : Theme.fg }
                Txt { text: Notifs.dnd ? "DND on" : "DND off"; color: Notifs.dnd ? Theme.bg : Theme.fg; font.pixelSize: 12 }
            }
            MouseArea { id: dndMa; anchors.fill: parent; hoverEnabled: true; onClicked: Notifs.dnd = !Notifs.dnd }
        }
        // Clear all
        Rectangle {
            visible: root.count > 0
            implicitWidth: clearRow.implicitWidth + 20
            implicitHeight: 28
            radius: Config.notifRadius
            color: Qt.alpha(Theme.red, clearMa.containsMouse ? 0.32 : 0.16)
            border { width: 1; color: Qt.alpha(Theme.red, 0.5) }
            Row {
                id: clearRow
                anchors.centerIn: parent
                spacing: 6
                Txt { text: ""; color: Theme.red }
                Txt { text: "Clear all"; color: Theme.red; font.pixelSize: 12 }
            }
            MouseArea { id: clearMa; anchors.fill: parent; hoverEnabled: true; onClicked: Notifs.clear() }
        }
    }

    // ---- empty state ----
    Rectangle {
        Layout.fillWidth: true
        visible: root.count === 0
        implicitHeight: 120
        radius: Config.notifRadius
        color: Qt.alpha(Theme.subtle, 0.35)
        Column {
            anchors.centerIn: parent
            spacing: 6
            Txt { anchors.horizontalCenter: parent.horizontalCenter; text: Notifs.dnd ? "" : ""; color: Theme.muted; font.pixelSize: 28 }
            Txt { anchors.horizontalCenter: parent.horizontalCenter; text: "You're all caught up"; font { pixelSize: 14; bold: true } }
            Txt {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Notifs.dnd ? "Do Not Disturb is on, popups are hidden" : "No new notifications"
                color: Theme.muted
                font.pixelSize: 12
            }
        }
    }

    // ---- list ----
    ListView {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, 460)
        visible: root.count > 0
        clip: true
        spacing: 8
        model: Notifs.list

        delegate: Rectangle {
            id: card
            required property var modelData
            readonly property bool critical: modelData.urgency === NotificationUrgency.Critical
            readonly property string icon: modelData.image
                || (modelData.appIcon ? Quickshell.iconPath(modelData.appIcon, true) ?? "" : "")
            readonly property int firstLabelled: {
                for (let i = 0; i < modelData.actions.length; i++) if (modelData.actions[i].text.trim()) return i;
                return -1;
            }
            readonly property string app: modelData.appName || "Notification"

            width: ListView.view.width
            height: content.implicitHeight + 24
            radius: Config.notifRadius
            color: Qt.alpha(Theme.subtle, hover.containsMouse ? 0.75 : 0.45)
            border { width: 1; color: critical ? Qt.alpha(Theme.red, 0.8) : "transparent" }

            // whole card: default action + dismiss. Sits below the content so buttons still get their clicks.
            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    const a = card.modelData.actions;
                    for (let i = 0; i < a.length; i++) if (a[i].identifier === "default") { a[i].invoke(); break }
                    card.modelData.dismiss();
                }
            }

            RowLayout {
                id: content
                anchors { fill: parent; margins: 12 }
                spacing: 12

                // app icon
                Rectangle {
                    Layout.alignment: Qt.AlignTop
                    implicitWidth: 40; implicitHeight: 40
                    radius: Config.notifRadius
                    color: Qt.alpha(Theme.bg, 0.6)
                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 28
                        visible: card.icon !== ""
                        source: card.icon
                    }
                    Txt {
                        anchors.centerIn: parent
                        visible: card.icon === ""
                        text: ""
                        color: card.critical ? Theme.red : Theme.accent
                        font.pixelSize: 18
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    // app · time · dismiss
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Txt {
                            Layout.fillWidth: true
                            text: card.app
                            color: card.critical ? Theme.red : Theme.muted
                            font { pixelSize: 11; bold: true; letterSpacing: 0.5 }
                        }
                        Rectangle {
                            visible: (Notifs.counts[card.modelData.id] ?? 1) > 1
                            implicitWidth: cnt.implicitWidth + 10
                            implicitHeight: 18
                            radius: Config.notifRadius
                            color: card.critical ? Theme.red : Theme.accent
                            Txt { id: cnt; anchors.centerIn: parent; text: "\u00d7" + (Notifs.counts[card.modelData.id] ?? 1); color: Theme.bg; font { pixelSize: 11; bold: true } }
                        }
                        Txt { text: root.ago(card.modelData.id); color: Theme.muted; font.pixelSize: 11 }
                        Txt {
                            text: ""
                            color: closeMa.containsMouse ? Theme.red : Theme.muted
                            MouseArea {
                                id: closeMa
                                anchors { fill: parent; margins: -6 }
                                hoverEnabled: true
                                onClicked: card.modelData.dismiss()
                            }
                        }
                    }

                    Txt {
                        Layout.fillWidth: true
                        text: card.modelData.summary
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        font { pixelSize: 14; bold: true }
                    }
                    Txt {
                        Layout.fillWidth: true
                        visible: text !== ""
                        text: card.modelData.body
                        color: Qt.alpha(Theme.fg, 0.8)
                        wrapMode: Text.Wrap
                        maximumLineCount: 4
                        font.pixelSize: 12
                    }

                    // labelled actions as buttons ("default" has no label and stays on the card click)
                    Flow {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        spacing: 8
                        Repeater {
                            model: card.modelData.actions
                            ActionButton {
                                required property var modelData
                                required property int index
                                primary: index === card.firstLabelled
                                text: modelData.text
                                visible: text.trim() !== ""
                                onClicked: { modelData.invoke(); card.modelData.dismiss() }
                            }
                        }
                    }
                }
            }
        }
    }
}
