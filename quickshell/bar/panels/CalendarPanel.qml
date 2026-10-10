import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import "../components"
import "../services"

ColumnLayout {
    signal close()

    id: c
    spacing: 8
    property date view: new Date()
    readonly property int first: new Date(view.getFullYear(), view.getMonth(), 1).getDay()

    SystemClock { id: clock; precision: SystemClock.Seconds }

    RowLayout {
        spacing: 8
        Txt { text: "\uf073"; color: Theme.accent; font.pixelSize: 16 }
        Txt { text: "Calendar"; font.bold: true }
    }
    Row {
        Layout.alignment: Qt.AlignHCenter
        spacing: 4
        Txt { text: Qt.formatTime(clock.date, "hh:mm:ss AP").split(" ")[0]; font.pixelSize: 44 }
        Txt { anchors.top: parent.top; anchors.topMargin: 6; text: Qt.formatTime(clock.date, "hh:mm:ss AP").split(" ")[1]; color: Theme.muted }
    }
    Txt {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: Qt.formatDate(clock.date, "dddd, MMMM d, yyyy")
        color: Theme.muted
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 10
        Txt { Layout.fillWidth: true; text: Qt.formatDate(c.view, "MMMM yyyy"); font.bold: true; color: Theme.accent }
        Txt { text: "Today"; MouseArea { anchors { fill: parent; margins: -6 } onClicked: c.view = new Date() } }
        Txt { text: "\uf053"; MouseArea { anchors { fill: parent; margins: -6 } onClicked: c.view = new Date(c.view.getFullYear(), c.view.getMonth() - 1, 1) } }
        Txt { text: "\uf054"; MouseArea { anchors { fill: parent; margins: -6 } onClicked: c.view = new Date(c.view.getFullYear(), c.view.getMonth() + 1, 1) } }
    }
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: grid.implicitHeight + 16
        radius: 10
        color: Qt.alpha(Theme.subtle, 0.5)
        Grid {
            id: grid
            anchors.centerIn: parent
            columns: 7
            Repeater {
                model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                Txt { width: 52; height: 30; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; text: modelData; color: Theme.muted }
            }
            Repeater {
                model: 42
                Rectangle {
                    required property int index
                    readonly property date d: new Date(c.view.getFullYear(), c.view.getMonth(), 1 - c.first + index)
                    readonly property bool inMonth: d.getMonth() === c.view.getMonth()
                    readonly property bool isToday: d.toDateString() === clock.date.toDateString()
                    width: 52; height: 34; radius: 8
                    color: isToday ? Theme.accent : "transparent"
                    Txt {
                        anchors.centerIn: parent
                        text: parent.d.getDate()
                        color: parent.isToday ? Theme.bg : parent.inMonth ? Theme.fg : Theme.subtle
                    }
                }
            }
        }
    }
}
