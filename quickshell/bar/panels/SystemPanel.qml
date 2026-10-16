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
    Card {
        visible: Sys.weather !== ""
        title: "Weather"
        glyph: "cloud"

        RowLayout {
            Layout.fillWidth: true
            Txt { icon: true; text: Sys.wxIcon(Sys.weather.split(" ")[0]); font.pixelSize: 24 }
            Txt { text: Sys.weather.replace(/^\S+\s+/, ""); font.pixelSize: 20; font.bold: true }
            Txt { Layout.fillWidth: true; text: Sys.weatherDesc; color: Theme.muted; horizontalAlignment: Text.AlignRight }
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Txt { icon: true; text: "location_on"; color: Theme.accent }
            Txt { Layout.fillWidth: true; text: Sys.weatherPlace || "Unknown location" }
        }
        Txt {
            Layout.fillWidth: true
            visible: Sys.weatherFeels !== ""
            text: "Feels " + Sys.weatherFeels + "  ·  Humidity " + Sys.weatherHumidity + "  ·  Wind " + Sys.weatherWind
            color: Theme.muted
            font.pixelSize: 11
            wrapMode: Text.Wrap
        }
        Txt {
            Layout.fillWidth: true
            text: Config.weatherLocation === ""
                ? "Location is guessed from your IP. Set weatherLocation in services/Config.qml to pin it."
                : "Location set in services/Config.qml"
            color: Theme.muted
            font.pixelSize: 10
            wrapMode: Text.Wrap
        }
        TapHandler { onTapped: Sys.refreshSlow() }   // click the card to refresh
    }
    ListRow {
        visible: Sys.kbActive !== ""
        text: Sys.kbActive
        sub: "Keyboard layout" + (Sys.kbMulti ? "" : " (single layout)")
    }
}
