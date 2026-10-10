import QtQuick
import QtQuick.Layouts
import "../components"
import "../services"

// Resource gauges + the slow-poll items (updates, weather, keyboard layout).
ColumnLayout {
    id: root
    signal close()
    spacing: 8

    Txt { text: "System"; font.bold: true }

    Card {
        RowLayout {
            Layout.fillWidth: true
            Gauge { Layout.fillWidth: true; value: Sys.cpu / 100; text: Math.round(Sys.cpu) + "%"; caption: "CPU" }
            Gauge { Layout.fillWidth: true; value: Sys.ram / 100; text: Sys.ram + "%"; caption: "RAM" }
            Gauge { Layout.fillWidth: true; value: Sys.disk / 100; text: Sys.disk + "%"; caption: "Disk" }
            Gauge {
                Layout.fillWidth: true
                value: Sys.temp / 100
                text: Math.round(Sys.temp) + "°"
                caption: "Temp"
                color: Sys.temp > 85 ? Theme.red : Theme.accent
            }
        }
    }

    ListRow {
        text: Sys.updates > 0 ? Sys.updates + " updates available" : "System is up to date"
        sub: "Click to update in a terminal"
        on: Sys.updates > 0
        onClicked: {
            Sys.updateSystem();
            root.close();
        }
    }
    ListRow {
        visible: Sys.weather !== ""
        text: Sys.weather
        sub: "Weather (click to refresh)"
        onClicked: Sys.refreshSlow()
    }
    ListRow {
        visible: Sys.kbActive !== ""
        text: Sys.kbActive
        sub: "Keyboard layout" + (Sys.kbMulti ? "" : " (single layout)")
    }
}
