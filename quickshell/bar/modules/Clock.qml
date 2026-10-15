import QtQuick
import Quickshell
import "../components"
import "../services"

// Time -> calendar dropdown
Btn {
    property var bar
    glyph: "schedule"; size: 17
    color: Theme.accent
    label: Qt.formatDateTime(clock.date, "hh:mm AP")
    onClicked: item => bar.toggle("calendar", item)

    SystemClock { id: clock; precision: SystemClock.Minutes }
}
