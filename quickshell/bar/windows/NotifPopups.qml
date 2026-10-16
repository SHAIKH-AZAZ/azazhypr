import QtQuick
import "../components"
import "../services"
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Notifications

// Popup stack, top-right. Each card slides in from the right edge and slides back out when it
// times out or is dismissed. Identical notifications are collapsed by Notifs (count badge).
PanelWindow {
    id: win

    readonly property int cardWidth: 340

    anchors { top: true; right: true }
    margins { top: 48 }
    implicitWidth: cardWidth + 8        // 8px gap to the screen edge; cards start fully outside this window
    implicitHeight: col.implicitHeight
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: Notifs.popups.length > 0 && !Notifs.dnd
    WlrLayershell.namespace: "quickshell-notifications"

    // keeps delegates alive across changes (a plain array would rebuild every card and restart its timeline)
    ScriptModel { id: shown; values: Notifs.popups.slice(-Config.notifMaxVisible) }

    Column {
        id: col
        width: win.cardWidth
        spacing: 6

        // neighbours glide into the gap left by a card that slid out
        move: Transition { NumberAnimation { properties: "y"; duration: 180; easing.type: Easing.OutCubic } }

        Repeater {
            model: shown

            Rectangle {
                id: pop
                required property var modelData
                readonly property bool critical: modelData.urgency === NotificationUrgency.Critical
                readonly property bool sticky: critical && Config.notifCriticalTimeout <= 0
                readonly property int count: Notifs.counts[modelData.id] ?? 1
                readonly property color tint: critical ? Theme.red
                    : modelData.urgency === NotificationUrgency.Low ? Theme.muted : Theme.accent
                readonly property string icon: modelData.image
                    || (modelData.appIcon ? Quickshell.iconPath(modelData.appIcon, true) ?? "" : "")
                // actions with a label become buttons; the unlabeled "default" one fires on click
                readonly property int labelled: {
                    let n = 0;
                    for (let i = 0; i < modelData.actions.length; i++) if (modelData.actions[i].text.trim()) n++;
                    return n;
                }

                readonly property int firstLabelled: {
                    for (let i = 0; i < modelData.actions.length; i++) if (modelData.actions[i].text.trim()) return i;
                    return -1;
                }

                // ---- slide in / out ----
                property bool leaving: false
                property bool dismissAfter: false
                function leave(dismiss) {
                    if (leaving) return;
                    dismissAfter = dismiss;
                    leaving = true;
                    x = win.implicitWidth;
                    opacity = 0;
                }
                function finish() {
                    Notifs.drop(modelData);
                    if (dismissAfter) modelData.dismiss();
                }
                x: win.implicitWidth
                opacity: 0
                Component.onCompleted: { x = 0; opacity = 1 }
                Behavior on x {
                    NumberAnimation {
                        duration: 240
                        easing.type: pop.leaving ? Easing.InCubic : Easing.OutCubic
                        onRunningChanged: if (!running && pop.leaving) pop.finish()
                    }
                }
                Behavior on opacity { NumberAnimation { duration: 200 } }

                width: win.cardWidth
                height: row.implicitHeight + 28
                radius: Config.notifRadius
                color: Qt.alpha(Theme.bg, 0.95)
                border { width: 1; color: critical ? Theme.red : Theme.subtle }

                // timeline: shrinks over the popup's lifetime, pauses on hover, then the card slides out.
                // critical uses Config.notifCriticalTimeout; 0 = stays until dismissed (bar stays full).
                property real timeLeft: 1
                NumberAnimation on timeLeft {
                    from: 1; to: 0
                    duration: pop.critical ? Math.max(1, Config.notifCriticalTimeout)
                        : Math.min(pop.modelData.expireTimeout > 0 ? pop.modelData.expireTimeout * 1000 : Config.notifTimeout, Config.notifMaxTimeout)
                    running: !pop.sticky && !pop.leaving
                    paused: hover.containsMouse
                    onFinished: pop.leave(false)
                }

                Row {
                    id: row
                    anchors { fill: parent; margins: 10; rightMargin: 30 }
                    spacing: 10

                    Item {
                        width: 36; height: 36
                        IconImage {
                            anchors.fill: parent
                            visible: pop.icon !== ""
                            source: pop.icon
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: pop.icon === ""
                            text: pop.critical ? "warning" : "info"
                            color: pop.tint
                            font { family: Theme.iconFont; pixelSize: 26 }
                        }
                    }
                    Column {
                        width: parent.width - 46
                        spacing: 2

                        // title + "x3" badge when identical notifications were merged
                        Row {
                            width: parent.width
                            spacing: 6
                            Text {
                                width: parent.width - (badge.visible ? badge.width + 6 : 0)
                                text: pop.modelData.summary
                                color: Theme.fg
                                elide: Text.ElideRight
                                font { family: Theme.font; pixelSize: 13; bold: true }
                            }
                            Rectangle {
                                id: badge
                                visible: pop.count > 1
                                width: badgeText.implicitWidth + 10
                                height: 18
                                radius: Config.notifRadius
                                color: pop.tint
                                Text {
                                    id: badgeText
                                    anchors.centerIn: parent
                                    text: "×" + pop.count
                                    color: Theme.bg
                                    font { family: Theme.font; pixelSize: 11; bold: true }
                                }
                            }
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
                                    required property int index
                                    primary: index === pop.firstLabelled
                                    text: modelData.text
                                    visible: text.trim() !== ""
                                    onClicked: {
                                        modelData.invoke();
                                        pop.leave(true);
                                    }
                                }
                            }
                        }
                    }
                }

                // timeline bar, boxy (no rounding), inset from the card edge
                Rectangle {
                    anchors { left: parent.left; bottom: parent.bottom; leftMargin: 10; bottomMargin: 5 }
                    width: (parent.width - 20) * pop.timeLeft
                    height: 3
                    color: pop.tint
                }

                MouseArea {
                    id: hover
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        const a = pop.modelData.actions;
                        for (let i = 0; i < a.length; i++) if (a[i].identifier === "default") { a[i].invoke(); break }
                        pop.leave(true);
                    }
                }

                Text {
                    anchors { top: parent.top; right: parent.right; topMargin: 6; rightMargin: 8 }
                    text: "close"
                    color: closeHit.containsMouse ? Theme.red : Theme.muted
                    font { family: Theme.iconFont; pixelSize: 16 }
                    MouseArea {
                        id: closeHit
                        anchors { fill: parent; margins: -4 }
                        hoverEnabled: true
                        onClicked: pop.leave(true)
                    }
                }
            }
        }
    }
}
