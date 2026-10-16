import QtQuick
import QtQuick.Layouts
import Quickshell
import "../components"
import "../services"

// Clock + month grid. Click a day to select it: shows its week/day number, relative distance and
// the notes you saved for it (Events.qml). Wheel over the grid changes month.
ColumnLayout {
    id: c
    signal close()
    spacing: 8

    readonly property int weekStart: Config.calendarMondayFirst ? 1 : 0
    readonly property var dayNames: Config.calendarMondayFirst
        ? ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"] : ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    property date view: new Date()      // any date inside the month being shown
    property date sel: new Date()       // selected day
    readonly property int lead: (new Date(view.getFullYear(), view.getMonth(), 1).getDay() - weekStart + 7) % 7

    SystemClock { id: clock; precision: SystemClock.Seconds }

    function startOfDay(d) { return new Date(d.getFullYear(), d.getMonth(), d.getDate()) }
    function sameDay(a, b) { return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate() }
    function dayOfYear(d) { return Math.round((startOfDay(d) - new Date(d.getFullYear(), 0, 1)) / 86400000) + 1 }
    function isoWeek(d) {
        const t = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
        t.setUTCDate(t.getUTCDate() + 4 - (t.getUTCDay() || 7));
        return Math.ceil(((t - new Date(Date.UTC(t.getUTCFullYear(), 0, 1))) / 86400000 + 1) / 7);
    }
    function relative(d) {
        const n = Math.round((startOfDay(d) - startOfDay(clock.date)) / 86400000);
        if (n === 0) return "Today";
        if (n === 1) return "Tomorrow";
        if (n === -1) return "Yesterday";
        return n > 0 ? "in " + n + " days" : -n + " days ago";
    }
    function goMonth(delta) { view = new Date(view.getFullYear(), view.getMonth() + delta, 1) }
    function goToday() { view = new Date(); sel = new Date() }

    // ---- header + clock ----
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Txt { icon: true; text: "calendar_month"; color: Theme.accent; font.pixelSize: 16 }
        Txt { Layout.fillWidth: true; text: "Calendar"; font.bold: true }
        Rectangle {
            implicitWidth: todayTxt.implicitWidth + 18
            implicitHeight: 26
            radius: Config.notifRadius
            color: todayMa.containsMouse ? Theme.accent : Qt.alpha(Theme.subtle, 0.8)
            Txt { id: todayTxt; anchors.centerIn: parent; text: "Today"; color: todayMa.containsMouse ? Theme.bg : Theme.fg; font.pixelSize: 12 }
            MouseArea { id: todayMa; anchors.fill: parent; hoverEnabled: true; onClicked: c.goToday() }
        }
    }
    Row {
        Layout.alignment: Qt.AlignHCenter
        spacing: 4
        Txt { text: Qt.formatTime(clock.date, "hh:mm:ss AP").split(" ")[0]; font.pixelSize: 40 }
        Txt { anchors.top: parent.top; anchors.topMargin: 6; text: Qt.formatTime(clock.date, "hh:mm:ss AP").split(" ")[1]; color: Theme.muted }
    }
    Txt {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: Qt.formatDate(clock.date, "dddd, MMMM d, yyyy")
        color: Theme.muted
    }

    // ---- month navigation ----
    RowLayout {
        Layout.fillWidth: true
        spacing: 4
        Txt { Layout.fillWidth: true; text: Qt.formatDate(c.view, "MMMM yyyy"); font.bold: true; font.pixelSize: 15; color: Theme.accent }
        Repeater {
            model: [
                { g: "keyboard_double_arrow_left", d: -12 },   // year back
                { g: "chevron_left", d: -1 },
                { g: "chevron_right", d: 1 },
                { g: "keyboard_double_arrow_right", d: 12 }     // year forward
            ]
            Rectangle {
                required property var modelData
                implicitWidth: 28; implicitHeight: 26
                radius: Config.notifRadius
                color: navMa.containsMouse ? Theme.subtle : "transparent"
                Txt { icon: true; anchors.centerIn: parent; text: parent.modelData.g; font.pixelSize: 17 }
                MouseArea { id: navMa; anchors.fill: parent; hoverEnabled: true; onClicked: c.goMonth(parent.modelData.d) }
            }
        }
    }

    // ---- grid ----
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: grid.implicitHeight + 16
        radius: Config.notifRadius
        color: Qt.alpha(Theme.subtle, 0.45)

        MouseArea {
            anchors.fill: parent
            onWheel: e => c.goMonth(e.angleDelta.y < 0 ? 1 : -1)
        }

        Grid {
            id: grid
            anchors.centerIn: parent
            columns: 8

            // header row: week-number column + day names
            Txt { width: 30; height: 28; text: "#"; color: Theme.muted; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            Repeater {
                model: c.dayNames
                Txt { width: 48; height: 28; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; text: modelData; color: Theme.muted }
            }

            // 6 weeks: [week number, 7 days]
            Repeater {
                model: 48
                Item {
                    id: cell
                    required property int index
                    readonly property int row: Math.floor(index / 8)
                    readonly property int col: index % 8
                    readonly property date d: new Date(c.view.getFullYear(), c.view.getMonth(), 1 - c.lead + row * 7 + (col - 1))
                    readonly property bool isWeek: col === 0
                    readonly property bool inMonth: d.getMonth() === c.view.getMonth()
                    readonly property bool isToday: c.sameDay(d, clock.date)
                    readonly property bool isSel: c.sameDay(d, c.sel)
                    readonly property int events: (Events.data[Events.key(d)] ?? []).length

                    width: isWeek ? 30 : 48
                    height: 36

                    Txt {
                        visible: cell.isWeek
                        anchors.centerIn: parent
                        text: c.isoWeek(new Date(c.view.getFullYear(), c.view.getMonth(), 1 - c.lead + cell.row * 7 + 1))
                        color: Theme.muted
                        font.pixelSize: 10
                    }

                    Rectangle {
                        visible: !cell.isWeek
                        anchors { fill: parent; margins: 2 }
                        radius: Config.notifRadius
                        color: cell.isToday ? Theme.accent : dayMa.containsMouse ? Qt.alpha(Theme.fg, 0.12) : "transparent"
                        border { width: cell.isSel && !cell.isToday ? 2 : 0; color: Theme.accent }

                        Txt {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: cell.events > 0 ? -3 : 0
                            text: cell.d.getDate()
                            color: cell.isToday ? Theme.bg : cell.inMonth ? Theme.fg : Theme.muted
                            opacity: cell.inMonth ? 1 : 0.55
                            font.bold: cell.isSel
                        }
                        Rectangle {   // has-notes dot
                            visible: cell.events > 0
                            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 4 }
                            width: 4; height: 4; radius: 2
                            color: cell.isToday ? Theme.bg : Theme.green
                        }
                        MouseArea {
                            id: dayMa
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                c.sel = cell.d;
                                if (!cell.inMonth) c.view = new Date(cell.d.getFullYear(), cell.d.getMonth(), 1);
                            }
                        }
                    }
                }
            }
        }
    }

    // ---- selected day ----
    Card {
        Layout.fillWidth: true

        RowLayout {
            Layout.fillWidth: true
            Txt { Layout.fillWidth: true; text: Qt.formatDate(c.sel, "dddd, d MMMM yyyy"); font { bold: true; pixelSize: 14 } }
            Txt { text: c.relative(c.sel); color: c.sameDay(c.sel, clock.date) ? Theme.accent : Theme.muted }
        }
        Txt {
            Layout.fillWidth: true
            text: "Week " + c.isoWeek(c.sel) + "  ·  Day " + c.dayOfYear(c.sel) + " of " + c.dayOfYear(new Date(c.sel.getFullYear(), 11, 31))
            color: Theme.muted
            font.pixelSize: 11
        }

        Repeater {
            model: Events.data[Events.key(c.sel)] ?? []
            RowLayout {
                required property var modelData
                required property int index
                Layout.fillWidth: true
                spacing: 8
                Rectangle { width: 6; height: 6; radius: 3; color: Theme.green; Layout.alignment: Qt.AlignVCenter }
                Txt { Layout.fillWidth: true; text: parent.modelData; wrapMode: Text.Wrap; maximumLineCount: 3 }
                Txt {
                    icon: true
                    text: "close"
                    color: delMa.containsMouse ? Theme.red : Theme.muted
                    MouseArea {
                        id: delMa
                        anchors { fill: parent; margins: -6 }
                        hoverEnabled: true
                        onClicked: Events.remove(c.sel, parent.parent.index)
                    }
                }
            }
        }
        Txt {
            visible: (Events.data[Events.key(c.sel)] ?? []).length === 0
            text: "Nothing saved for this day"
            color: Theme.muted
            font.pixelSize: 12
        }

        // add a note: type + Enter
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 32
            radius: Config.notifRadius
            color: Qt.alpha(Theme.bg, 0.6)
            border { width: 1; color: input.activeFocus ? Theme.accent : Theme.subtle }
            TextInput {
                id: input
                anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.fg
                selectionColor: Theme.accent
                selectedTextColor: Theme.bg
                clip: true
                font { family: Theme.font; pixelSize: 12 }
                onAccepted: { Events.add(c.sel, text); text = "" }
            }
            Txt {
                anchors { fill: parent; leftMargin: 10 }
                verticalAlignment: Text.AlignVCenter
                visible: input.text === "" && !input.activeFocus
                text: "Add a note for this day, press Enter"
                color: Theme.muted
                font.pixelSize: 12
            }
            MouseArea { anchors.fill: parent; onClicked: input.forceActiveFocus(); z: -1 }
        }
    }
}
