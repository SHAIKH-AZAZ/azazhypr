import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../components"
import "../services"

// Wi-Fi: header with rescan + radio switch, the active connection, then nearby networks.
// Click a network: saved/open ones connect at once, secured new ones ask for the password inline.
ColumnLayout {
    signal close()

    id: n
    spacing: 8
    property var nets: []           // [{ ssid, sig, sec, saved, on }]
    property string ip: ""
    property bool scanning: false
    property string ask: ""         // ssid whose password row is open
    property string busy: ""        // ssid being connected
    property string err: ""

    function sigIcon(s) {
        return s >= 75 ? "signal_wifi_4_bar" : s >= 50 ? "network_wifi_3_bar" : s >= 25 ? "network_wifi_2_bar" : "network_wifi_1_bar";
    }
    function refresh(rescan) { scanning = true; list.rescan = rescan ? "yes" : "auto"; list.running = true }
    function connect(net, pass) {
        err = ""; busy = net.ssid; ask = "";
        act.command = net.saved ? ["nmcli", "con", "up", "id", net.ssid]
            : pass ? ["nmcli", "dev", "wifi", "connect", net.ssid, "password", pass]
            : ["nmcli", "dev", "wifi", "connect", net.ssid];
        act.running = true;
    }
    function pick(net) {
        if (net.on || busy) return;
        if (net.saved || net.sec === "") connect(net, "");
        else ask = ask === net.ssid ? "" : net.ssid;
    }

    Component.onCompleted: refresh(false)

    // one pass: networks, saved profiles, ip of the wifi device
    Process {
        id: list
        property string rescan: "auto"
        command: ["sh", "-c",
            "nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list --rescan " + rescan + "; echo '##'; " +
            "nmcli -t -f NAME,TYPE con show; echo '##'; " +
            "nmcli -g IP4.ADDRESS dev show \"$(nmcli -t -f DEVICE,TYPE dev | awk -F: '$2==\"wifi\"{print $1; exit}')\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const [w, c, a] = text.split("##\n");
                const saved = new Set((c ?? "").split("\n").filter(l => l.endsWith(":802-11-wireless")).map(l => l.slice(0, -16).replace(/\\:/g, ":")));
                const seen = {};
                for (const l of (w ?? "").split("\n")) {
                    const m = l.match(/^(\*| ):(\d+):([^:]*):(.+)$/);
                    if (!m) continue;
                    const ssid = m[4].replace(/\\:/g, ":");
                    const on = m[1] === "*";
                    if (seen[ssid] && !on && seen[ssid].sig >= +m[2]) continue;
                    const sec = m[3] === "--" ? "" : m[3].split(" ").pop();
                    seen[ssid] = { ssid, sig: +m[2], sec, saved: saved.has(ssid), on: on || (seen[ssid]?.on ?? false) };
                }
                n.nets = Object.values(seen).sort((x, y) => y.sig - x.sig);
                n.ip = (a ?? "").trim().split("\n")[0].replace(/\/\d+$/, "");
                n.scanning = false;
            }
        }
    }
    Process {
        id: act
        stderr: StdioCollector { id: actErr }
        onExited: code => {
            if (code !== 0) n.err = (actErr.text.trim().split("\n").pop() || "Failed").replace(/^Error:\s*/, "");
            n.busy = "";
            n.refresh(false);
        }
    }

    // ---------------- header ----------------
    RowLayout {
        spacing: 10
        Txt { icon: true; text: Sys.wifiRadio ? "wifi" : "wifi_off"; font.pixelSize: 20; color: Sys.wifiRadio ? Theme.accent : Theme.muted }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Txt { Layout.fillWidth: true; text: "Network"; font.bold: true }
            Txt {
                Layout.fillWidth: true
                color: Theme.muted
                font.pixelSize: 11
                text: !Sys.wifiRadio ? "Off" : n.busy ? "Connecting to " + n.busy + "…" : n.scanning ? "Scanning…" : Sys.wifi ? "Connected" : "Not connected"
            }
        }
        Txt {
            visible: Sys.wifiRadio
            icon: true; text: "refresh"; font.pixelSize: 18
            color: ref.containsMouse ? Theme.accent : Theme.fg
            RotationAnimation on rotation { running: n.scanning; from: 0; to: 360; duration: 900; loops: Animation.Infinite; alwaysRunToEnd: true }
            MouseArea { id: ref; anchors { fill: parent; margins: -6 } hoverEnabled: true; onClicked: n.refresh(true) }
        }
        Txt {
            icon: true; text: "settings"; font.pixelSize: 18
            color: cfg.containsMouse ? Theme.accent : Theme.fg
            MouseArea { id: cfg; anchors { fill: parent; margins: -6 } hoverEnabled: true; onClicked: { Sys.run("nm-connection-editor"); n.close() } }
        }
        Rectangle {
            implicitWidth: 40; implicitHeight: 22; radius: 11
            color: Sys.wifiRadio ? Theme.accent : Theme.subtle
            Rectangle {
                width: 16; height: 16; radius: 8
                y: 3; x: Sys.wifiRadio ? parent.width - width - 3 : 3
                color: Sys.wifiRadio ? Theme.bg : Theme.fg
                Behavior on x { NumberAnimation { duration: 120 } }
            }
            MouseArea { anchors.fill: parent; onClicked: { Sys.toggleWifi(); if (Sys.wifiRadio) n.refresh(true) } }
        }
    }

    Txt { visible: n.err !== ""; Layout.fillWidth: true; text: n.err; color: Theme.red; font.pixelSize: 11; wrapMode: Text.Wrap }

    // ---------------- active ----------------
    Txt { visible: Sys.wifiRadio && Sys.wifi; text: "ACTIVE CONNECTION"; color: Theme.muted; font { pixelSize: 10; bold: true; letterSpacing: 1 } }
    Rectangle {
        visible: Sys.wifiRadio && Sys.wifi
        Layout.fillWidth: true
        implicitHeight: 56
        radius: 10
        color: Qt.alpha(Theme.subtle, 0.5)
        RowLayout {
            anchors { fill: parent; leftMargin: 8; rightMargin: 10 }
            spacing: 10
            Rectangle {
                implicitWidth: 38; implicitHeight: 38; radius: 9
                color: Qt.alpha(Theme.accent, 0.18)
                Txt { anchors.centerIn: parent; icon: true; text: n.sigIcon(n.nets.find(x => x.on)?.sig ?? 100); color: Theme.accent; font.pixelSize: 20 }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                Txt { Layout.fillWidth: true; text: Sys.ssid; font.bold: true }
                Txt { Layout.fillWidth: true; text: n.ip || "…"; color: Theme.muted; font.pixelSize: 11 }
            }
            Pill { visible: actHover.containsMouse; text: "Disconnect"; danger: true; onClicked: { act.command = ["nmcli", "con", "down", "id", Sys.ssid]; act.running = true } }
            Txt { visible: !actHover.containsMouse; text: "Connected"; color: Theme.muted; font.pixelSize: 11 }
        }
        MouseArea { id: actHover; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
    }

    // ---------------- available ----------------
    Txt { visible: Sys.wifiRadio; text: "AVAILABLE NETWORKS"; color: Theme.muted; font { pixelSize: 10; bold: true; letterSpacing: 1 } }
    Txt { visible: !Sys.wifiRadio; Layout.fillWidth: true; text: "Wi-Fi is off"; color: Theme.muted; horizontalAlignment: Text.AlignHCenter; Layout.topMargin: 12; Layout.bottomMargin: 12 }
    Txt { visible: Sys.wifiRadio && !n.scanning && n.nets.filter(x => !x.on).length === 0; text: "No networks found"; color: Theme.muted }

    Rectangle {
        visible: Sys.wifiRadio && n.nets.some(x => !x.on)
        Layout.fillWidth: true
        implicitHeight: rows.implicitHeight
        radius: 10
        color: Qt.alpha(Theme.subtle, 0.5)
        clip: true
        Column {
            id: rows
            width: parent.width
            Repeater {
                model: n.nets.filter(x => !x.on)
                Column {
                    id: row
                    required property var modelData
                    required property int index
                    width: rows.width
                    Rectangle { visible: row.index > 0; width: parent.width; height: 1; color: Qt.alpha(Theme.fg, 0.06) }
                    Rectangle {
                        width: parent.width; height: 50
                        color: ma.containsMouse ? Qt.alpha(Theme.fg, 0.05) : "transparent"
                        RowLayout {
                            anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                            spacing: 12
                            Txt { icon: true; text: n.sigIcon(row.modelData.sig); font.pixelSize: 20 }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Txt { Layout.fillWidth: true; text: row.modelData.ssid }
                                Txt {
                                    Layout.fillWidth: true; color: Theme.muted; font.pixelSize: 11
                                    text: n.busy === row.modelData.ssid ? "Connecting…"
                                        : [row.modelData.sec || "Open", row.modelData.saved ? "Saved" : ""].filter(x => x).join(" · ")
                                }
                            }
                            Txt { visible: row.modelData.sec !== ""; icon: true; text: "lock"; color: Theme.muted; font.pixelSize: 16 }
                        }
                        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: n.pick(row.modelData) }
                    }
                    // password row
                    RowLayout {
                        visible: n.ask === row.modelData.ssid
                        width: parent.width - 24; x: 12
                        height: visible ? 44 : 0
                        spacing: 8
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 32; radius: 8
                            color: Theme.bg
                            border { width: 1; color: pw.activeFocus ? Theme.accent : Theme.subtle }
                            TextInput {
                                id: pw
                                anchors { fill: parent; leftMargin: 10; rightMargin: 32 }
                                verticalAlignment: TextInput.AlignVCenter
                                color: Theme.fg
                                font { family: Theme.font; pixelSize: 12 }
                                echoMode: eye.shown ? TextInput.Normal : TextInput.Password
                                clip: true
                                onVisibleChanged: if (visible) { text = ""; forceActiveFocus() }
                                Keys.onReturnPressed: if (text) n.connect(row.modelData, text)
                                Keys.onEscapePressed: n.ask = ""
                                Txt { visible: !pw.text; anchors.verticalCenter: parent.verticalCenter; text: "Password"; color: Theme.muted; font.pixelSize: 12 }
                            }
                            Txt {
                                id: eye
                                property bool shown: false
                                anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                icon: true; text: shown ? "visibility_off" : "visibility"; color: Theme.muted; font.pixelSize: 16
                                MouseArea { anchors { fill: parent; margins: -4 } onClicked: eye.shown = !eye.shown }
                            }
                        }
                        Pill { text: "Connect"; primary: true; onClicked: if (pw.text) n.connect(row.modelData, pw.text) }
                    }
                }
            }
        }
    }
}
