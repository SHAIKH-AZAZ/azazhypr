import QtQuick
import QtQuick.Layouts
import "../components"
import "../services"

Rectangle {
    id: d
    property var dev
    readonly property bool connecting: dev.state === 3
    readonly property bool disconnecting: dev.state === 2
    readonly property bool busy: connecting || disconnecting || dev.pairing
    Layout.fillWidth: true
    implicitHeight: 50
    radius: 10
    color: hover.containsMouse ? Qt.alpha(Theme.subtle, 0.6) : "transparent"
    MouseArea { id: hover; anchors.fill: parent; hoverEnabled: true }

    RowLayout {
        anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
        spacing: 10
        Txt {
            Layout.preferredWidth: 24
            horizontalAlignment: Text.AlignHCenter
            text: Sys.btGlyph(d.dev.icon)
            font.pixelSize: 18
            color: d.dev.connected ? Theme.accent : Theme.fg
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Txt { Layout.fillWidth: true; text: d.dev.name; color: d.dev.connected ? Theme.accent : Theme.fg }
            Txt {
                Layout.fillWidth: true
                color: Theme.muted
                font.pixelSize: 11
                text: d.dev.pairing ? "Pairing\u2026"
                    : d.connecting ? "Connecting\u2026"
                    : d.disconnecting ? "Disconnecting\u2026"
                    : (d.dev.connected ? "Connected" : d.dev.paired ? "Paired" : "Available")
                      + (d.dev.batteryAvailable ? "  \u00b7  \uf240 " + Math.round(d.dev.battery * 100) + "%" : "")
                      + (d.dev.trusted ? "  \u00b7  trusted" : "")
            }
        }
        Pill {
            visible: d.dev.paired && !d.busy
            text: "Forget"; danger: true
            onClicked: d.dev.forget()
        }
        Pill {
            text: d.busy ? "\u2026" : d.dev.connected ? "Disconnect" : d.dev.paired ? "Connect" : "Pair"
            primary: !d.dev.connected && !d.busy
            onClicked: {
                if (d.busy) { if (d.dev.pairing) d.dev.cancelPair(); return }
                if (d.dev.connected) d.dev.disconnect();
                else if (d.dev.paired) d.dev.connect();
                else d.dev.pair();
            }
        }
    }
}
