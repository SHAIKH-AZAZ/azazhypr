import QtQuick
import QtQuick.Layouts
import "../components"
import "../services"

// One device row inside a grouped card (BluetoothPanel). Click: connect / disconnect / pair.
// Hover: action pill, plus Forget for paired devices. `first` hides the top separator.
Item {
    id: d
    property var dev
    property bool first: false
    readonly property bool connecting: dev.state === 3
    readonly property bool disconnecting: dev.state === 2
    readonly property bool busy: connecting || disconnecting || dev.pairing
    width: parent?.width ?? 0
    implicitHeight: 54

    function primary() {
        if (busy) { if (dev.pairing) dev.cancelPair(); return }
        if (dev.connected) dev.disconnect();
        else if (dev.paired) dev.connect();
        else dev.pair();
    }

    Rectangle { visible: !d.first; width: parent.width; height: 1; color: Qt.alpha(Theme.fg, 0.06) }
    Rectangle { anchors.fill: parent; color: hover.hovered ? Qt.alpha(Theme.fg, 0.05) : "transparent" }
    MouseArea { anchors.fill: parent; onClicked: d.primary() }
    HoverHandler { id: hover }   // passive: stays hovered over the pill / forget button too

    RowLayout {
        anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
        spacing: 12
        Rectangle {
            implicitWidth: 36; implicitHeight: 36; radius: 9
            color: d.dev.connected ? Qt.alpha(Theme.accent, 0.18) : "transparent"
            Txt {
                anchors.centerIn: parent
                text: Sys.btIcon(d.dev.icon ?? "")
                icon: true
                font.pixelSize: 20
                color: d.dev.connected ? Theme.accent : Theme.fg
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            Txt { Layout.fillWidth: true; text: d.dev.name; font.bold: d.dev.connected }
            Txt {
                Layout.fillWidth: true
                color: Theme.muted
                font.pixelSize: 11
                text: d.dev.pairing ? "Pairing…"
                    : d.connecting ? "Connecting…"
                    : d.disconnecting ? "Disconnecting…"
                    : [d.dev.connected ? "Connected" : d.dev.paired ? "Paired" : "Available",
                       d.dev.batteryAvailable ? Math.round(d.dev.battery * 100) + "%" : "",
                       d.dev.trusted ? "Trusted" : ""].filter(x => x).join(" · ")
            }
        }
        Txt {
            visible: d.dev.paired && !d.busy && hover.hovered
            icon: true; text: "delete"; font.pixelSize: 18
            color: fm.containsMouse ? Theme.red : Theme.muted
            MouseArea { id: fm; anchors { fill: parent; margins: -5 } hoverEnabled: true; onClicked: d.dev.forget() }
        }
        Pill {
            visible: hover.hovered || d.busy
            text: d.busy ? (d.dev.pairing ? "Cancel" : "…") : d.dev.connected ? "Disconnect" : d.dev.paired ? "Connect" : "Pair"
            primary: !d.dev.connected && !d.busy
            danger: d.dev.connected
            onClicked: d.primary()
        }
    }
}
