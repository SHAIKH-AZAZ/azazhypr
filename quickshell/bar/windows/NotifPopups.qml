import QtQuick
import "../components"
import "../services"
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Notifications

PanelWindow {
    id: win

    anchors { top: true; right: true }
    margins { top: 48; right: 8 }
    implicitWidth: 340
    implicitHeight: col.implicitHeight
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: Notifs.popups.length > 0 && !Notifs.dnd
    WlrLayershell.namespace: "quickshell-notifications"

    Column {
        id: col
        width: parent.width
        spacing: 8

        Repeater {
            model: Notifs.popups.slice(-Config.notifMaxVisible)

            Rectangle {
                id: pop
                required property var modelData
                // actions with a label become buttons; the unlabeled "default" one fires on click
                readonly property int labelled: {
                    let n = 0;
                    for (let i = 0; i < modelData.actions.length; i++) if (modelData.actions[i].text) n++;
                    return n;
                }
                width: col.width
                height: row.implicitHeight + 20
                readonly property string icon: modelData.image
                    || (modelData.appIcon ? Quickshell.iconPath(modelData.appIcon, true) ?? "" : "")
                radius: 12
                color: Qt.alpha(Theme.bg, 0.95)
                border { width: 1; color: modelData.urgency === NotificationUrgency.Critical ? Theme.red : Theme.subtle }

                // critical stays until dismissed
                Timer {
                    interval: Math.min(pop.modelData.expireTimeout > 0 ? pop.modelData.expireTimeout * 1000 : Config.notifTimeout, Config.notifMaxTimeout)
                    running: !(Config.notifCriticalSticky && pop.modelData.urgency === NotificationUrgency.Critical) && !hover.containsMouse
                    onTriggered: Notifs.drop(pop.modelData)
                }

                Row {
                    id: row
                    anchors { fill: parent; margins: 10; rightMargin: 30 }
                    spacing: 10

                    IconImage {
                        implicitSize: 36
                        visible: pop.icon !== ""
                        source: pop.icon
                    }
                    Column {
                        width: parent.width - (parent.children[0].visible ? 46 : 0)
                        spacing: 2
                        Text {
                            width: parent.width
                            text: pop.modelData.summary
                            color: Theme.fg
                            elide: Text.ElideRight
                            font { family: Theme.font; pixelSize: 13; bold: true }
                        }
                        Text {
                            width: parent.width
                            visible: text !== ""
                            text: pop.modelData.body
                            color: Theme.muted
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            font { family: Theme.font; pixelSize: 12 }
                        }
                        Row {
                            visible: pop.labelled > 0
                            spacing: 8
                            topPadding: 6
                            Repeater {
                                model: pop.modelData.actions
                                ActionButton {
                                    required property var modelData
                                    text: modelData.text
                                    visible: text !== ""
                                    onClicked: {
                                        modelData.invoke();
                                        Notifs.drop(pop.modelData);
                                    }
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    id: hover
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        const a = pop.modelData.actions;
                        for (let i = 0; i < a.length; i++) if (a[i].identifier === "default") { a[i].invoke(); break }
                        Notifs.drop(pop.modelData);
                        pop.modelData.dismiss();
                    }
                }

                Text {
                    anchors { top: parent.top; right: parent.right; topMargin: 6; rightMargin: 8 }
                    text: "\uf00d"
                    color: closeHit.containsMouse ? Theme.red : Theme.muted
                    font { family: Theme.font; pixelSize: 14 }
                    MouseArea {
                        id: closeHit
                        anchors { fill: parent; margins: -4 }
                        hoverEnabled: true
                        onClicked: { Notifs.drop(pop.modelData); pop.modelData.dismiss() }
                    }
                }
            }
        }
    }
}
