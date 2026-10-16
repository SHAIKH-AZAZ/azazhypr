import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../components"
import "../services"

// Focus panel: header + settings, four stat tiles, month chart (daily / weekly), calendar,
// and the selected day's breakdown per app. Data: services/Activity.qml.
ColumnLayout {
    id: c
    signal close()
    spacing: 10

    readonly property int weekStart: Config.calendarMondayFirst ? 1 : 0
    readonly property var dayNames: Config.calendarMondayFirst
        ? ["M", "T", "W", "T", "F", "S", "S"] : ["S", "M", "T", "W", "T", "F", "S"]

    property date view: new Date()              // any date inside the month shown
    property string sel: Activity.today         // selected day, yyyy-MM-dd
    property int mode: 0                        // chart: 0 daily, 1 weekly
    property int hov: -1                        // hovered bar
    property bool showSettings: false
    property bool showAll: false

    readonly property int days: new Date(view.getFullYear(), view.getMonth() + 1, 0).getDate()
    readonly property int lead: (new Date(view.getFullYear(), view.getMonth(), 1).getDay() - weekStart + 7) % 7
    readonly property int rows: Math.ceil((lead + days) / 7)
    readonly property int weeks: rows

    function dayKey(n) { return Activity.key(new Date(view.getFullYear(), view.getMonth(), n)) }
    function goMonth(d) { view = new Date(view.getFullYear(), view.getMonth() + d, 1) }
    function axis(s) { return s === 0 ? "0" : s >= 3600 && s % 3600 === 0 ? (s / 3600) + "h" : Math.round(s / 60) + "m" }
    function selDate() { return new Date(sel + "T12:00:00") }

    // chart values: seconds per day, or per calendar-grid week
    readonly property var vals: {
        void Activity.rev;
        const out = [];
        if (mode === 0) {
            for (let i = 1; i <= days; i++) out.push(Activity.total(dayKey(i)));
        } else {
            for (let w = 0; w < weeks; w++) out.push(0);
            for (let i = 1; i <= days; i++) out[Math.floor((lead + i - 1) / 7)] += Activity.total(dayKey(i));
        }
        return out;
    }
    readonly property real monthTotal: { let t = 0; for (const v of (mode === 0 ? vals : [])) t += v; return t }
    readonly property real monthSum: { void Activity.rev; let t = 0; for (let i = 1; i <= days; i++) t += Activity.total(dayKey(i)); return t }
    readonly property real bestDay: { void Activity.rev; let b = 0; for (let i = 1; i <= days; i++) b = Math.max(b, Activity.total(dayKey(i))); return b }
    readonly property real ceilSec: Math.max(mode === 0 ? 7200 : 14400, Math.ceil(Math.max(0, ...vals) / 3600) * 3600)
    readonly property int selBar: {
        const d = selDate();
        if (d.getFullYear() !== view.getFullYear() || d.getMonth() !== view.getMonth()) return -1;
        return mode === 0 ? d.getDate() - 1 : Math.floor((lead + d.getDate() - 1) / 7);
    }
    readonly property int activeBar: hov >= 0 ? hov : selBar

    // small flat button used in the header
    component IconBtn: Rectangle {
        property string glyph
        property bool on: false
        signal clicked
        implicitWidth: 30; implicitHeight: 30
        radius: 8
        color: ma.containsMouse || on ? Qt.alpha(Theme.fg, 0.12) : Qt.alpha(Theme.subtle, 0.4)
        border { width: 1; color: on ? Theme.green : Theme.subtle }
        Txt { icon: true; anchors.centerIn: parent; text: parent.glyph; color: parent.on ? Theme.green : Theme.fg; font.pixelSize: 17 }
        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: parent.clicked() }
    }

    // ================= header =================
    RowLayout {
        Layout.fillWidth: true
        spacing: 10
        Txt { icon: true; text: "show_chart"; color: Theme.green; font.pixelSize: 24 }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Txt { text: "Focus"; font { pixelSize: 17; bold: true } }
            Txt { text: Activity.paused ? "Tracking paused" : "Track your productive time"; color: Activity.paused ? Theme.yellow : Theme.muted; font.pixelSize: 11 }
        }
        IconBtn { glyph: "chevron_left"; onClicked: c.goMonth(-1) }
        IconBtn { glyph: "settings"; on: c.showSettings; onClicked: c.showSettings = !c.showSettings }
        IconBtn { glyph: "chevron_right"; onClicked: c.goMonth(1) }
    }

    // ================= settings (gear) =================
    Rectangle {
        Layout.fillWidth: true
        visible: c.showSettings
        implicitHeight: set.implicitHeight + 20
        radius: 10
        color: Qt.alpha(Theme.subtle, 0.4)
        border { width: 1; color: Theme.subtle }
        ColumnLayout {
            id: set
            anchors { fill: parent; margins: 10 }
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Txt { Layout.fillWidth: true; text: "Tracking" }
                Rectangle {
                    implicitWidth: 78; implicitHeight: 26; radius: 13
                    color: Activity.paused ? Qt.alpha(Theme.yellow, 0.2) : Qt.alpha(Theme.green, 0.2)
                    border { width: 1; color: Activity.paused ? Theme.yellow : Theme.green }
                    Txt { anchors.centerIn: parent; text: Activity.paused ? "Paused" : "Running"; color: Activity.paused ? Theme.yellow : Theme.green; font.pixelSize: 12 }
                    MouseArea { anchors.fill: parent; onClicked: Activity.setPaused(!Activity.paused) }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Txt { Layout.fillWidth: true; text: "Pause after idle" }
                IconBtn { glyph: "remove"; implicitWidth: 26; implicitHeight: 26; onClicked: Activity.setIdle(Activity.idleSec - 30) }
                Txt { Layout.minimumWidth: 52; horizontalAlignment: Text.AlignHCenter; text: Activity.idleSec >= 60 ? (Activity.idleSec / 60).toFixed(Activity.idleSec % 60 ? 1 : 0) + " min" : Activity.idleSec + " s" }
                IconBtn { glyph: "add"; implicitWidth: 26; implicitHeight: 26; onClicked: Activity.setIdle(Activity.idleSec + 30) }
            }
            RowLayout {
                Layout.fillWidth: true
                Txt { Layout.fillWidth: true; text: "Today's data" }
                Rectangle {
                    implicitWidth: 78; implicitHeight: 26; radius: 8
                    color: Qt.alpha(Theme.red, rst.containsMouse ? 0.35 : 0.15)
                    border { width: 1; color: Qt.alpha(Theme.red, 0.6) }
                    Txt { anchors.centerIn: parent; text: "Reset"; color: Theme.red; font.pixelSize: 12 }
                    MouseArea { id: rst; anchors.fill: parent; hoverEnabled: true; onClicked: Activity.resetToday() }
                }
            }
        }
    }

    // ================= stat tiles =================
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Repeater {
            model: [
                { g: "schedule", col: Theme.green, k: "Today", v: Activity.fmt(Activity.total(Activity.today)), hot: true },
                { g: "local_fire_department", col: Theme.purple, k: "Streak", v: Activity.streak() + (Activity.streak() === 1 ? " day" : " days"), hot: false },
                { g: "calendar_month", col: Theme.blue, k: "Month", v: Activity.fmt(c.monthSum), hot: false },
                { g: "emoji_events", col: Theme.orange, k: "Best day", v: Activity.fmt(c.bestDay), hot: false }
            ]
            Rectangle {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: 54
                radius: 10
                color: modelData.hot ? Qt.alpha(modelData.col, 0.12) : Qt.alpha(Theme.subtle, 0.35)
                border { width: 1; color: modelData.hot ? Qt.alpha(modelData.col, 0.55) : Theme.subtle }
                RowLayout {
                    anchors { fill: parent; leftMargin: 9; rightMargin: 6 }
                    spacing: 7
                    Txt { icon: true; text: modelData.g; color: modelData.col; font.pixelSize: 21 }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Txt { Layout.fillWidth: true; text: modelData.v; font { pixelSize: 14; bold: true } }
                        Txt { Layout.fillWidth: true; text: modelData.k; color: Theme.muted; font.pixelSize: 10 }
                    }
                }
            }
        }
    }

    // ================= chart =================
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: chartCol.implicitHeight + 20
        radius: 10
        color: Qt.alpha(Theme.subtle, 0.3)
        border { width: 1; color: Theme.subtle }

        ColumnLayout {
            id: chartCol
            anchors { fill: parent; margins: 10 }
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                Txt { Layout.fillWidth: true; text: Qt.formatDate(c.view, "MMMM yyyy"); font { pixelSize: 15; bold: true } }
                Rectangle {   // Daily / Weekly
                    implicitWidth: modeRow.implicitWidth + 20; implicitHeight: 28; radius: 8
                    color: Qt.alpha(Theme.bg, 0.6)
                    border { width: 1; color: Theme.subtle }
                    Row {
                        id: modeRow
                        anchors.centerIn: parent
                        spacing: 8
                        Txt { text: c.mode === 0 ? "Daily" : "Weekly"; font.pixelSize: 12 }
                        Txt { icon: true; text: "expand_more"; color: Theme.muted }
                    }
                    MouseArea { anchors.fill: parent; onClicked: { c.mode = (c.mode + 1) % 2; c.hov = -1 } }
                }
            }

            Item {
                id: chart
                Layout.fillWidth: true
                implicitHeight: 140

                readonly property real axisW: 30
                readonly property real plotH: 100
                readonly property real plotW: width - axisW
                readonly property int n: c.vals.length
                readonly property real gap: c.mode === 0 ? 3 : 14
                readonly property real bw: Math.max(2, (plotW - gap * (n - 1)) / n)

                // y axis labels
                Repeater {
                    model: [0, 0.5, 1]
                    Txt {
                        required property real modelData
                        x: 0
                        y: chart.plotH - modelData * chart.plotH - height / 2 + 8
                        text: c.axis(Math.round(c.ceilSec * modelData))
                        color: Theme.muted
                        font.pixelSize: 10
                    }
                }
                // dashed grid
                Canvas {
                    x: chart.axisW; y: 8
                    width: chart.plotW; height: chart.plotH + 1
                    onPaint: {
                        const g = getContext("2d");
                        g.clearRect(0, 0, width, height);
                        g.strokeStyle = Qt.alpha(Theme.fg, 0.16);
                        g.lineWidth = 1;
                        g.setLineDash([3, 4]);
                        for (const f of [0, 0.5, 1]) {
                            const y = Math.round(height - 1 - f * chart.plotH) + 0.5;
                            g.beginPath(); g.moveTo(0, y); g.lineTo(width, y); g.stroke();
                        }
                    }
                    Component.onCompleted: requestPaint()
                    onWidthChanged: requestPaint()
                    Connections { target: Theme; function onFgChanged() { requestPaint() } }
                }
                // bars
                Item {
                    x: chart.axisW; y: 8
                    width: chart.plotW; height: chart.plotH
                    Repeater {
                        model: c.vals
                        Item {
                            id: bar
                            required property int index
                            required property real modelData
                            x: index * (chart.bw + chart.gap)
                            width: chart.bw
                            height: parent.height
                            readonly property bool active: index === c.activeBar
                            Rectangle {
                                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                                height: bar.modelData > 0 ? Math.max(3, Math.min(1, bar.modelData / c.ceilSec) * parent.height) : 1
                                radius: 2
                                color: bar.modelData <= 0 ? Theme.subtle : bar.active ? Theme.green : Qt.alpha(Theme.green, 0.5)
                                Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                            }
                            MouseArea {
                                anchors { fill: parent; leftMargin: -chart.gap / 2; rightMargin: -chart.gap / 2 }
                                hoverEnabled: true
                                onEntered: c.hov = bar.index
                                onExited: if (c.hov === bar.index) c.hov = -1
                                onClicked: {
                                    // daily: select that day; weekly: select the first day of that week in this month
                                    const day = c.mode === 0 ? bar.index + 1 : Math.max(1, bar.index * 7 - c.lead + 1);
                                    c.sel = c.dayKey(day);
                                }
                            }
                        }
                    }
                    // tooltip for the hovered / selected bar
                    Rectangle {
                        id: tip
                        readonly property int b: c.activeBar
                        visible: b >= 0 && b < chart.n
                        readonly property real bx: b * (chart.bw + chart.gap) + chart.bw / 2
                        readonly property real val: visible ? c.vals[b] : 0
                        width: tipCol.implicitWidth + 16; height: tipCol.implicitHeight + 10
                        x: Math.max(0, Math.min(parent.width - width, bx - width / 2))
                        y: Math.max(-4, parent.height - Math.max(3, Math.min(1, val / c.ceilSec) * parent.height) - height - 6)
                        radius: 6
                        color: Qt.alpha(Theme.bg, 0.95)
                        border { width: 1; color: Theme.subtle }
                        Column {
                            id: tipCol
                            anchors.centerIn: parent
                            Txt { anchors.horizontalCenter: parent.horizontalCenter; text: Activity.fmt(tip.val); font { pixelSize: 12; bold: true } }
                            Txt {
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: Theme.muted
                                font.pixelSize: 10
                                text: c.mode === 0 ? Qt.formatDate(new Date(c.view.getFullYear(), c.view.getMonth(), tip.b + 1), "d MMM") : "Week " + (tip.b + 1)
                            }
                        }
                    }
                }
                // x labels
                Repeater {
                    model: chart.n
                    Txt {
                        required property int index
                        readonly property bool shown: c.mode === 1 || index === 0 || (index + 1) % 5 === 0
                        visible: shown
                        x: chart.axisW + index * (chart.bw + chart.gap) + chart.bw / 2 - width / 2
                        y: chart.plotH + 14
                        text: c.mode === 0 ? index + 1 : "W" + (index + 1)
                        color: Theme.muted
                        font.pixelSize: 10
                    }
                }
            }
        }
    }

    // ================= calendar =================
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: grid.implicitHeight + 20
        radius: 10
        color: Qt.alpha(Theme.subtle, 0.3)
        border { width: 1; color: Theme.subtle }
        MouseArea { anchors.fill: parent; onWheel: e => c.goMonth(e.angleDelta.y < 0 ? 1 : -1) }

        Grid {
            id: grid
            anchors.centerIn: parent
            columns: 7
            spacing: 5
            Repeater {
                model: c.dayNames
                Txt { width: 52; height: 18; horizontalAlignment: Text.AlignHCenter; text: modelData; color: Theme.muted; font.pixelSize: 11 }
            }
            Repeater {
                model: c.rows * 7
                Rectangle {
                    id: cell
                    required property int index
                    readonly property int n: index - c.lead + 1
                    readonly property bool inMonth: n >= 1 && n <= c.days
                    readonly property string k: inMonth ? c.dayKey(n) : ""
                    readonly property bool isSel: inMonth && k === c.sel
                    readonly property bool isToday: inMonth && k === Activity.today
                    readonly property real sec: inMonth ? Activity.total(k) : 0
                    width: 52; height: 30
                    radius: 7
                    color: isSel ? Qt.alpha(Theme.green, 0.22) : Qt.alpha(Theme.subtle, inMonth ? (cma.containsMouse ? 0.7 : 0.45) : 0.2)
                    border { width: isSel ? 2 : 0; color: Theme.green }
                    Txt {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: cell.sec > 0 ? -2 : 0
                        visible: cell.inMonth
                        text: cell.n
                        font { pixelSize: 12; bold: cell.isSel || cell.isToday }
                        color: cell.isToday ? Theme.green : Theme.fg
                    }
                    Rectangle {   // has-activity dot
                        visible: cell.sec > 0
                        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 4 }
                        width: 4; height: 4; radius: 2
                        color: Theme.green
                    }
                    MouseArea { id: cma; anchors.fill: parent; hoverEnabled: true; enabled: cell.inMonth; onClicked: c.sel = cell.k }
                }
            }
        }
    }

    // ================= selected day =================
    Rectangle {
        id: dayCard
        Layout.fillWidth: true
        implicitHeight: dayCol.implicitHeight + 20
        radius: 10
        color: Qt.alpha(Theme.subtle, 0.3)
        border { width: 1; color: Theme.subtle }

        readonly property var list: Activity.apps(c.sel)
        readonly property real topSec: list.length ? list[0].sec : 1
        readonly property var shownList: c.showAll ? list : list.slice(0, 3)

        ColumnLayout {
            id: dayCol
            anchors { fill: parent; margins: 10 }
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Txt { Layout.fillWidth: true; text: Qt.formatDate(c.selDate(), "dddd, d MMMM"); font { pixelSize: 16; bold: true } }
                Txt { text: Activity.fmt(Activity.total(c.sel)); color: Theme.green; font { pixelSize: 16; bold: true } }
            }
            Txt {
                visible: dayCard.list.length === 0
                text: "No activity tracked this day"
                color: Theme.muted
                font.pixelSize: 12
            }
            Repeater {
                model: dayCard.shownList
                RowLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 10
                    Rectangle {   // app icon, letter tile when there is no icon
                        implicitWidth: 30; implicitHeight: 30; radius: 8
                        color: Qt.alpha(Theme.bg, 0.6)
                        IconImage {
                            anchors.centerIn: parent
                            implicitSize: 22
                            visible: source !== ""
                            source: Activity.icon(modelData.app)
                        }
                        Txt {
                            anchors.centerIn: parent
                            visible: Activity.icon(modelData.app) === ""
                            text: modelData.name.charAt(0)
                            color: Theme.green
                            font { bold: true; pixelSize: 14 }
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        RowLayout {
                            Layout.fillWidth: true
                            Txt { Layout.fillWidth: true; text: modelData.name; font.pixelSize: 13 }
                            Txt { text: Activity.fmt(modelData.sec); color: Theme.muted; font.pixelSize: 12 }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            height: 5; radius: 2.5
                            color: Qt.alpha(Theme.bg, 0.7)
                            Rectangle {
                                height: parent.height; radius: parent.radius
                                width: parent.width * Math.min(1, modelData.sec / dayCard.topSec)
                                color: Theme.green
                            }
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.subtle }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Txt { icon: true; text: "schedule"; color: Theme.muted; font.pixelSize: 15 }
                Txt {
                    Layout.fillWidth: true
                    color: Theme.muted
                    font.pixelSize: 12
                    readonly property int s: Activity.sessions(c.sel)
                    text: (s > 0 ? s + (s === 1 ? " session" : " sessions") + "  ·  " : "") + Activity.fmt(Activity.total(c.sel)) + " focused"
                }
                Rectangle {
                    visible: dayCard.list.length > 3
                    implicitWidth: detRow.implicitWidth + 20; implicitHeight: 30; radius: 8
                    color: detMa.containsMouse ? Qt.alpha(Theme.fg, 0.12) : "transparent"
                    border { width: 1; color: Theme.subtle }
                    Row {
                        id: detRow
                        anchors.centerIn: parent
                        spacing: 8
                        Txt { text: c.showAll ? "Show less" : "View Details"; font.pixelSize: 12 }
                        Txt { icon: true; text: c.showAll ? "arrow_upward" : "arrow_forward"; color: Theme.muted }
                    }
                    MouseArea { id: detMa; anchors.fill: parent; hoverEnabled: true; onClicked: c.showAll = !c.showAll }
                }
            }
        }
    }
}
