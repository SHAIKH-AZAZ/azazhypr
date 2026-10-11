import QtQuick
import QtQuick.Layouts
import "../components"
import "../services"

// Focus city: a month skyline (one building per day, taller = more focus), a heatmap calendar,
// and a per-app breakdown for the selected day. Data comes from services/Activity.qml.
ColumnLayout {
    id: c
    signal close()
    spacing: 8

    readonly property real fullDay: 6 * 3600        // a day with this much focus = a full-height building
    readonly property int weekStart: Config.calendarMondayFirst ? 1 : 0
    readonly property var dayNames: Config.calendarMondayFirst
        ? ["M", "T", "W", "T", "F", "S", "S"] : ["S", "M", "T", "W", "T", "F", "S"]

    property date view: new Date()              // any date inside the month shown
    property string sel: Activity.today         // selected day, yyyy-MM-dd
    readonly property int days: new Date(view.getFullYear(), view.getMonth() + 1, 0).getDate()
    readonly property int lead: (new Date(view.getFullYear(), view.getMonth(), 1).getDay() - weekStart + 7) % 7

    function dayKey(n) { return Activity.key(new Date(view.getFullYear(), view.getMonth(), n)) }
    function goMonth(d) { view = new Date(view.getFullYear(), view.getMonth() + d, 1) }
    // 0 = nothing .. 4 = 4h+
    function level(sec) { return sec <= 0 ? 0 : sec < 1800 ? 1 : sec < 3600 ? 2 : sec < 7200 ? 3 : 4 }
    function shade(sec) { const l = level(sec); return l === 0 ? Qt.alpha(Theme.subtle, 0.5) : Qt.alpha(Theme.green, 0.2 + l * 0.2) }

    readonly property real monthTotal: { void Activity.rev; let t = 0; for (let i = 1; i <= days; i++) t += Activity.total(dayKey(i)); return t }
    readonly property real bestDay: { void Activity.rev; let b = 0; for (let i = 1; i <= days; i++) b = Math.max(b, Activity.total(dayKey(i))); return b }

    // ---- header ----
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Txt { text: ""; color: Theme.green; font.pixelSize: 16 }
        Txt { Layout.fillWidth: true; text: "Focus"; font.bold: true }
        Repeater {
            model: [{ g: "", d: -1 }, { g: "", d: 1 }]
            Rectangle {
                required property var modelData
                implicitWidth: 28; implicitHeight: 26
                radius: Config.notifRadius
                color: navMa.containsMouse ? Theme.subtle : "transparent"
                Txt { anchors.centerIn: parent; text: parent.modelData.g }
                MouseArea { id: navMa; anchors.fill: parent; hoverEnabled: true; onClicked: c.goMonth(parent.modelData.d) }
            }
        }
    }

    // ---- stats ----
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Repeater {
            model: [
                { k: "Today", v: Activity.fmt(Activity.total(Activity.today)) },
                { k: "Streak", v: Activity.streak() + (Activity.streak() === 1 ? " day" : " days") },
                { k: Qt.formatDate(c.view, "MMM"), v: Activity.fmt(c.monthTotal) },
                { k: "Best day", v: Activity.fmt(c.bestDay) }
            ]
            Rectangle {
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: 52
                radius: Config.notifRadius
                color: Qt.alpha(Theme.subtle, 0.45)
                Column {
                    anchors.centerIn: parent
                    spacing: 2
                    Txt { anchors.horizontalCenter: parent.horizontalCenter; text: parent.parent.modelData.v; font { pixelSize: 15; bold: true } }
                    Txt { anchors.horizontalCenter: parent.horizontalCenter; text: parent.parent.modelData.k; color: Theme.muted; font.pixelSize: 10 }
                }
            }
        }
    }

    // ---- skyline ----
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 112
        radius: Config.notifRadius
        color: Qt.alpha(Theme.subtle, 0.45)

        Txt {
            x: 10; y: 6
            text: Qt.formatDate(c.view, "MMMM yyyy")
            color: Theme.muted
            font { pixelSize: 10; letterSpacing: 1 }
        }
        Item {
            id: city
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: 10; rightMargin: 10; bottomMargin: 10 }
            height: 84
            readonly property real bw: (width - (c.days - 1) * 2) / c.days

            // ground
            Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.subtle }

            Repeater {
                model: c.days
                Item {
                    id: bld
                    required property int index
                    readonly property string k: c.dayKey(index + 1)
                    readonly property real sec: Activity.total(k)
                    readonly property bool isSel: k === c.sel
                    readonly property bool isToday: k === Activity.today

                    x: index * (city.bw + 2)
                    width: city.bw
                    height: city.height
                    z: isSel ? 2 : 0

                    Rectangle {
                        id: body
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; bottomMargin: 1 }
                        height: bld.sec > 0 ? Math.max(5, Math.min(1, bld.sec / c.fullDay) * (city.height - 6)) : 2
                        radius: 1
                        color: bld.isSel ? Theme.accent : bld.sec > 0 ? Qt.alpha(Theme.green, 0.45 + 0.55 * Math.min(1, bld.sec / c.fullDay)) : Theme.subtle
                        Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }

                        // lit windows on tall buildings
                        Column {
                            visible: body.height > 18 && city.bw > 5
                            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 4 }
                            spacing: 4
                            Repeater {
                                model: Math.max(0, Math.floor((body.height - 8) / 7))
                                Rectangle {
                                    width: 2; height: 2
                                    color: Theme.yellow
                                    opacity: (index + bld.index) % 3 === 0 ? 0.35 : 0.9
                                }
                            }
                        }
                    }
                    // today marker
                    Rectangle {
                        visible: bld.isToday
                        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: -5 }
                        width: 4; height: 2
                        color: Theme.accent
                    }
                    MouseArea { anchors.fill: parent; onClicked: c.sel = bld.k }
                }
            }
        }
    }

    // ---- heatmap calendar ----
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: heat.implicitHeight + 16
        radius: Config.notifRadius
        color: Qt.alpha(Theme.subtle, 0.45)

        MouseArea { anchors.fill: parent; onWheel: e => c.goMonth(e.angleDelta.y < 0 ? 1 : -1) }

        Grid {
            id: heat
            anchors.centerIn: parent
            columns: 7
            spacing: 4
            Repeater {
                model: c.dayNames
                Txt { width: 48; height: 18; horizontalAlignment: Text.AlignHCenter; text: modelData; color: Theme.muted; font.pixelSize: 10 }
            }
            Repeater {
                model: 42
                Item {
                    id: cell
                    required property int index
                    readonly property int n: index - c.lead + 1
                    readonly property bool inMonth: n >= 1 && n <= c.days
                    readonly property string k: inMonth ? c.dayKey(n) : ""
                    readonly property real sec: inMonth ? Activity.total(k) : 0
                    width: 48; height: 26
                    visible: inMonth

                    Rectangle {
                        anchors.fill: parent
                        radius: Config.notifRadius
                        color: c.shade(cell.sec)
                        border { width: cell.k === c.sel ? 2 : cell.k === Activity.today ? 1 : 0; color: Theme.accent }
                        Txt {
                            anchors.centerIn: parent
                            text: cell.n
                            font.pixelSize: 11
                            color: cell.sec > 0 ? Theme.fg : Theme.muted
                        }
                    }
                    MouseArea { anchors.fill: parent; enabled: cell.inMonth; onClicked: c.sel = cell.k }
                }
            }
        }
    }
    RowLayout {
        Layout.alignment: Qt.AlignRight
        spacing: 4
        Txt { text: "Less"; color: Theme.muted; font.pixelSize: 10 }
        Repeater {
            model: 5
            Rectangle { width: 12; height: 12; radius: 2; color: c.shade(index === 0 ? 0 : [0, 900, 2700, 5400, 9000][index]) }
        }
        Txt { text: "More"; color: Theme.muted; font.pixelSize: 10 }
    }

    // ---- selected day ----
    Card {
        Layout.fillWidth: true
        id: dayCard
        readonly property var rows: Activity.apps(c.sel)
        readonly property real topSec: rows.length ? rows[0].sec : 1

        RowLayout {
            Layout.fillWidth: true
            Txt {
                Layout.fillWidth: true
                text: Qt.formatDate(new Date(c.sel + "T12:00:00"), "dddd, d MMMM")
                font { bold: true; pixelSize: 14 }
            }
            Txt { text: Activity.fmt(Activity.total(c.sel)); color: Theme.green; font { bold: true; pixelSize: 14 } }
        }
        Txt {
            visible: dayCard.rows.length === 0
            text: "No activity tracked this day"
            color: Theme.muted
            font.pixelSize: 12
        }
        Repeater {
            model: dayCard.rows.slice(0, 6)
            ColumnLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: 3
                RowLayout {
                    Layout.fillWidth: true
                    Txt { Layout.fillWidth: true; text: modelData.name; font.pixelSize: 12 }
                    Txt { text: Activity.fmt(modelData.sec); color: Theme.muted; font.pixelSize: 11 }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 4
                    color: Qt.alpha(Theme.bg, 0.6)
                    Rectangle {
                        height: parent.height
                        width: parent.width * (modelData.sec / dayCard.topSec)
                        color: Theme.green
                    }
                }
            }
        }
        Txt {
            Layout.fillWidth: true
            visible: Config.showActivity
            text: "Counts the focused window every " + Config.activityTickSec + "s; paused after " + Config.activityIdleSec + "s idle."
            color: Theme.muted
            font.pixelSize: 10
            wrapMode: Text.Wrap
        }
    }
}
