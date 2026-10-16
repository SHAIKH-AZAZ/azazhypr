import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "../components"
import "../services"

// Battery panel: big percentage + state, level bar, draw / capacity / health, charge limit,
// power profile. Data: UPower display device; charge thresholds are read from sysfs.
ColumnLayout {
    id: b
    signal close()
    spacing: 12

    readonly property var d: UPower.displayDevice
    readonly property real pct: d?.percentage ?? 0
    readonly property bool charging: d?.state === UPowerDeviceState.Charging
    readonly property bool full: d?.state === UPowerDeviceState.FullyCharged
    readonly property real secs: charging ? (d?.timeToFull ?? 0) : (d?.timeToEmpty ?? 0)
    readonly property string stateText: charging ? "Charging" : full ? "Fully charged" : UPower.onBattery ? "On battery" : "Plugged in"
    readonly property color tone: charging || full ? Theme.green : pct < 0.15 ? Theme.red : pct < 0.4 ? Theme.yellow : Theme.green

    property int limitEnd: -1       // charge_control_end_threshold, -1 = not supported
    property int limitStart: -1
    property int healthPct: -1      // UPower "capacity" (full charge vs design), when the QML property is unavailable

    function hm(s) { return Math.floor(s / 3600) + "h " + String(Math.floor(s % 3600 / 60)).padStart(2, "0") + "m" }

    Process {
        running: true
        command: ["sh", "-c", "for b in /sys/class/power_supply/BAT*; do [ -r $b/charge_control_end_threshold ] && { echo end=$(cat $b/charge_control_end_threshold); [ -r $b/charge_control_start_threshold ] && echo start=$(cat $b/charge_control_start_threshold); break; }; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const l of text.split("\n")) {
                    if (l.startsWith("end=")) b.limitEnd = +l.slice(4);
                    else if (l.startsWith("start=")) b.limitStart = +l.slice(6);
                }
            }
        }
    }

    Process {
        running: true
        command: ["sh", "-c", "upower -i $(upower -e | grep -i BAT | head -1) 2>/dev/null | awk '/^ *capacity:/{gsub(\"%\",\"\",$2); print $2; exit}'"]
        stdout: StdioCollector { onStreamFinished: { const v = parseFloat(text); if (!isNaN(v)) b.healthPct = Math.round(v) } }
    }

    // ---- header ----
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Txt { icon: true; text: "battery_full"; color: Theme.muted; font.pixelSize: 16 }
        Txt { Layout.fillWidth: true; text: "Battery"; font { pixelSize: 15; bold: true } }
    }

    // ---- level ----
    RowLayout {
        Layout.fillWidth: true
        spacing: 10
        Txt { text: Math.round(b.pct * 100) + "%"; font { pixelSize: 44; bold: true } }
        ColumnLayout {
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: 8
            spacing: 0
            Txt { text: b.stateText; font { pixelSize: 13; bold: true } color: b.tone }
            Txt {
                visible: b.secs > 0 && !b.full
                text: b.hm(b.secs) + (b.charging ? " to full" : " left")
                color: Theme.muted
                font.pixelSize: 11
            }
        }
    }
    Rectangle {
        Layout.fillWidth: true
        height: 8; radius: 4
        color: Qt.alpha(Theme.fg, 0.15)
        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, b.pct))
            height: parent.height; radius: parent.radius
            color: b.tone
            Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        }
        // charge limit marker
        Rectangle {
            visible: b.limitEnd > 0 && b.limitEnd < 100
            x: parent.width * b.limitEnd / 100 - 1
            width: 2; height: parent.height + 6; y: -3
            color: Theme.fg; opacity: 0.6
        }
    }

    // ---- stats ----
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 4
        Repeater {
            model: [
                { v: Math.abs(b.d?.changeRate ?? 0).toFixed(1) + "W", k: "DRAW" },
                { v: Math.round(b.d?.energyCapacity ?? 0) + " Wh", k: "CAPACITY" },
                { v: b.d?.healthSupported ? Math.round(b.d.healthPercentage) + "%" : b.healthPct >= 0 ? b.healthPct + "%" : "--", k: "HEALTH" }
            ]
            ColumnLayout {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                spacing: 2
                Txt { Layout.alignment: Qt.AlignHCenter; text: modelData.v; font { pixelSize: 15; bold: true } }
                Txt { Layout.alignment: Qt.AlignHCenter; text: modelData.k; color: Theme.muted; font { pixelSize: 10; letterSpacing: 1 } }
            }
        }
    }

    // ---- charge limit ----
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6
        Txt { text: "CHARGE LIMIT"; color: Theme.muted; font { pixelSize: 10; letterSpacing: 1 } }
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Txt { icon: true; text: "info"; color: Theme.muted; font.pixelSize: 12 }
            Txt {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                color: Theme.muted
                font.pixelSize: 11
                text: b.limitEnd > 0
                    ? "Stops charging at " + b.limitEnd + "%" + (b.limitStart > 0 ? ", resumes below " + b.limitStart + "%" : "") + ". Set by firmware or BIOS."
                    : "Charge limit not supported on this device"
            }
        }
    }

    // ---- power profile ----
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6
        Txt { text: "POWER PROFILE"; color: Theme.muted; font { pixelSize: 10; letterSpacing: 1 } }
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 38
            radius: 10
            color: Qt.alpha(Theme.subtle, 0.45)
            RowLayout {
                anchors { fill: parent; margins: 3 }
                spacing: 3
                Repeater {
                    model: [
                        { g: "eco", t: "Saver", p: PowerProfile.PowerSaver, show: true },
                        { g: "balance", t: "Balanced", p: PowerProfile.Balanced, show: true },
                        { g: "rocket_launch", t: "Performance", p: PowerProfile.Performance, show: PowerProfiles.hasPerformanceProfile }
                    ].filter(x => x.show)
                    Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 8
                        readonly property bool on: PowerProfiles.profile === modelData.p
                        color: on ? Qt.alpha(Theme.fg, 0.18) : pma.containsMouse ? Qt.alpha(Theme.fg, 0.08) : "transparent"
                        Row {
                            anchors.centerIn: parent
                            spacing: 6
                            Txt { icon: true; text: modelData.g; color: parent.parent.on ? Theme.green : Theme.muted; font.pixelSize: 12 }
                            Txt { text: modelData.t; color: parent.parent.on ? Theme.fg : Theme.muted; font { pixelSize: 12; bold: parent.parent.on } }
                        }
                        MouseArea { id: pma; anchors.fill: parent; hoverEnabled: true; onClicked: PowerProfiles.profile = modelData.p }
                    }
                }
            }
        }
    }
}
