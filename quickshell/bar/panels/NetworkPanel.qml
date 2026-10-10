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

    id: n
    spacing: 6
    property var nets: []

    Process {
        running: true
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,ACTIVE", "dev", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const seen = {};
                for (const l of text.trim().split("\n")) {
                    const m = l.match(/^(.*):(\d+):(yes|no)$/);
                    if (!m || !m[1] || seen[m[1]]) continue;
                    seen[m[1]] = { ssid: m[1].replace(/\\:/g, ":"), sig: +m[2], on: m[3] === "yes" };
                }
                n.nets = Object.values(seen).sort((a, b) => b.sig - a.sig).slice(0, 7);
            }
        }
    }

    RowLayout {
        Txt { Layout.fillWidth: true; text: Sys.wifi ? Sys.ssid : "Not connected"; font.bold: true }
        Txt {
            text: ""
            font.pixelSize: 16
            MouseArea { anchors { fill: parent; margins: -6 } onClicked: { Sys.run("nm-connection-editor"); close() } }
        }
    }
    Repeater {
        model: n.nets
        ListRow {
            required property var modelData
            text: modelData.ssid
            sub: modelData.sig + "%"
            on: modelData.on
            onClicked: Sys.run("nmcli", "dev", "wifi", "connect", modelData.ssid)
        }
    }
}
