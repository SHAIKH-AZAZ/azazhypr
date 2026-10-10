pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris

// Shared system state + actions.
Singleton {
    id: root

    // toggles
    property bool inhibit: false
    property bool barHidden: false
    property bool recording: false
    property bool sunset: false
    property bool wifiRadio: true
    property bool airplane: false

    // sampled by scripts/poll.sh
    property string ssid: ""
    property int bright: 0       // percent
    property real down: 0        // bytes/s
    property real up: 0
    property real cpu: 0         // percent
    property int ram: 0          // percent
    property int disk: 0         // percent
    property real temp: 0        // celsius
    property string kbActive: ""
    property string kbLayouts: ""

    // slow poll (Config.slowPollMs)
    property int updates: 0
    property string weather: ""

    property real _rx: 0
    property string _pacman: ""
    property real _tx: 0
    property real _ct: 0
    property real _ci: 0

    readonly property bool wifi: ssid !== ""
    readonly property bool kbMulti: kbLayouts.indexOf(",") >= 0
    readonly property string kbShort: {
        const m = kbActive.match(/\(([^)]+)\)/);
        return (m ? m[1] : kbActive.slice(0, 2)).toUpperCase();
    }
    readonly property var sink: Pipewire.defaultAudioSink?.audio
    readonly property var source: Pipewire.defaultAudioSource?.audio
    readonly property var player: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null
    readonly property bool playing: Mpris.players.values.some(p => p.isPlaying)

    PwObjectTracker { objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource] }

    Process {
        id: poll
        command: ["sh", Quickshell.shellPath("scripts/poll.sh")]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const l of text.split("\n")) {
                    const i = l.indexOf("=");
                    if (i < 0) continue;
                    const k = l.slice(0, i), v = l.slice(i + 1).trim();
                    switch (k) {
                    case "net": {
                        const [rx, tx] = v.split(" ").map(Number);
                        if (root._rx > 0) {
                            root.down = Math.max(0, (rx - root._rx) / 2);
                            root.up = Math.max(0, (tx - root._tx) / 2);
                        }
                        root._rx = rx; root._tx = tx;
                        break;
                    }
                    case "cpu": {
                        const [t, idle] = v.split(" ").map(Number);
                        if (root._ct > 0 && t > root._ct)
                            root.cpu = 100 * (1 - (idle - root._ci) / (t - root._ct));
                        root._ct = t; root._ci = idle;
                        break;
                    }
                    case "ram": root.ram = +v; break;
                    case "disk": root.disk = +v; break;
                    case "temp": root.temp = +v / 1000; break;
                    case "bright": root.bright = +v; break;
                    case "rec": root.recording = v === "1"; break;
                    case "sunset": root.sunset = v === "1"; break;
                    case "wifiradio": root.wifiRadio = v === "enabled"; break;
                    case "airplane": root.airplane = v === "1"; break;
                    case "kb": {
                        const [a, lay] = v.split("|");
                        root.kbActive = a ?? "";
                        root.kbLayouts = lay ?? "";
                        break;
                    }
                    case "pacman":
                        // package db changed (any terminal, any tool) -> recount updates shortly
                        if (root._pacman !== "" && root._pacman !== v) recount.restart();
                        root._pacman = v;
                        break;
                    case "ssid": root.ssid = v; break;
                    }
                }
            }
        }
    }
    Timer { interval: 2000; running: true; repeat: true; triggeredOnStart: true; onTriggered: poll.running = true }

    Process {
        id: upd
        command: ["sh", "-c", "checkupdates 2>/dev/null | wc -l"]
        stdout: StdioCollector { onStreamFinished: root.updates = +text.trim() || 0 }
    }
    Process {
        id: wx
        command: ["sh", "-c", 'curl -fsS --max-time 8 "wttr.in/$1?format=%c+%t" 2>/dev/null', "sh", Config.weatherLocation]
        stdout: StdioCollector { onStreamFinished: root.weather = text.trim().replace(/\s+/g, " ") }
    }
    Timer { id: recount; interval: 3000; onTriggered: root.refreshSlow() }

    // run the upgrade in a terminal; recount when that terminal closes
    Process {
        id: updater
        command: [Config.terminal, "-e", "sh", "-c", "sudo pacman -Syu; echo; read -p 'Done. Press Enter to close ' _"]
        onRunningChanged: if (!running) root.refreshSlow()
    }
    function updateSystem() { updater.running = true }

    function refreshSlow() {
        if (Config.showUpdates) upd.running = true;
        if (Config.showWeather) wx.running = true;
    }
    Timer { interval: Config.slowPollMs; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.refreshSlow() }

    // Hyprland lua config wants `hl.dsp.*` expressions, legacy wants plain dispatchers
    function gotoWorkspace(id) {
        Hyprland.dispatch(Hyprland.usingLua ? `hl.dsp.focus({ workspace = ${id} })` : `workspace ${id}`);
    }
    function focusWindow(address) {
        const a = address.startsWith("0x") ? address : "0x" + address;
        Hyprland.dispatch(Hyprland.usingLua ? `hl.dsp.focus({ window = "address:${a}" })` : `focuswindow address:${a}`);
    }
    function logout() { Hyprland.dispatch(Hyprland.usingLua ? "hl.dsp.exit()" : "exit") }

    function btGlyph(icon) {
        if (/headset|headphone/.test(icon)) return "";
        if (/keyboard/.test(icon)) return "";
        if (/mouse/.test(icon)) return "";
        if (/phone/.test(icon)) return "";
        if (/computer|laptop/.test(icon)) return "";
        if (/gaming|joystick/.test(icon)) return "";
        if (/speaker|audio/.test(icon)) return "";
        return "";
    }

    function run(...cmd) { Quickshell.execDetached(cmd) }
    function fmt(b) { return b >= 1048576 ? (b / 1048576).toFixed(1) + "MB" : Math.round(b / 1024) + "KB" }
    function fmtRate(b) { return b >= 1048576 ? [(b / 1048576).toFixed(1), "MB/s"] : [(b / 1024).toFixed(1), "KB/s"] }
    function fmtTime(s) { s = Math.max(0, Math.floor(s || 0)); return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0") }
    function clamp(v) { return Math.max(0, Math.min(1, v)) }
    function setVol(a, v) { if (a) a.volume = clamp(v) }
    function setBright(p) {
        bright = Math.max(1, Math.min(100, Math.round(p)));
        run("brightnessctl", "set", bright + "%");
    }
    function toggleSunset() {
        sunset = !sunset;
        run("sh", "-c", "pkill -x hyprsunset || exec hyprsunset -t 4000");
    }
    function toggleRecord() {
        recording = !recording;
        run("sh", "-c", "pkill -INT -x wf-recorder || exec wf-recorder -f ~/Videos/rec-$(date +%s).mp4");
    }
    function toggleWifi() {
        wifiRadio = !wifiRadio;
        run("nmcli", "radio", "wifi", wifiRadio ? "on" : "off");
    }
    function toggleAirplane() {
        airplane = !airplane;
        run("rfkill", airplane ? "block" : "unblock", "all");
    }
}
