pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Daily focus tracker. Every Config.activityTickSec seconds the focused window class gets that
// many seconds added to today's total, unless the session is idle (IdleMonitor).
// Stored as JSON, outside the dotfiles:
//   ~/.local/share/quickshell-bar/activity.json   { "2026-10-11": { "kitty": 5400, "google-chrome": 1800 } }
Singleton {
    id: root

    property string dir: Quickshell.env("HOME") + "/.local/share/quickshell-bar"
    property var data: ({})
    property int rev: 0                 // bumps on every change so bindings re-read `data`
    property bool idle: false
    property bool dirty: false
    readonly property string today: Qt.formatDate(clock.date, "yyyy-MM-dd")

    SystemClock { id: clock; precision: SystemClock.Minutes }

    function key(d) { return Qt.formatDate(d, "yyyy-MM-dd") }
    function total(k) {
        void rev;
        const d = data[k];
        if (!d) return 0;
        let t = 0;
        for (const a in d) t += d[a];
        return t;
    }
    // [{ app, name, sec }] biggest first
    function apps(k) {
        void rev;
        const d = data[k] ?? {};
        return Object.keys(d).map(a => ({ app: a, name: pretty(a), sec: d[a] })).sort((a, b) => b.sec - a.sec);
    }
    // consecutive days up to today with at least 10 minutes of focus (today may still be in progress)
    function streak() {
        void rev;
        let n = 0;
        const d = new Date();
        if (total(key(d)) < 600) d.setDate(d.getDate() - 1);
        while (total(key(d)) >= 600) { n++; d.setDate(d.getDate() - 1); }
        return n;
    }
    function fmt(s) {
        const h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60);
        return h > 0 ? h + "h " + String(m).padStart(2, "0") + "m" : m + "m";
    }
    // com.microsoft.VSCode -> VSCode, google-chrome -> Google Chrome
    function pretty(cls) {
        const last = cls.split(".").pop().replace(/[-_]+/g, " ");
        return last.charAt(0).toUpperCase() + last.slice(1);
    }

    function count(app) {
        if (!app) return;
        const k = key(new Date());
        const d = data[k] ?? (data[k] = {});
        d[app] = (d[app] ?? 0) + Config.activityTickSec;
        rev++;
        dirty = true;
    }
    function save() { file.setText(JSON.stringify(data)); dirty = false }

    // who has focus: hyprctl, one call per tick
    Process {
        id: focus
        command: ["sh", "-c", "hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty'"]
        stdout: StdioCollector { onStreamFinished: root.count(text.trim()) }
    }
    Timer {
        interval: Config.activityTickSec * 1000
        running: Config.showActivity
        repeat: true
        onTriggered: if (!root.idle) focus.running = true
    }
    Timer { interval: 30000; running: true; repeat: true; onTriggered: if (root.dirty) root.save() }

    IdleMonitor {
        enabled: Config.showActivity
        timeout: Config.activityIdleSec
        respectInhibitors: true         // watching a video does not count as idle
        onIsIdleChanged: root.idle = isIdle
    }

    Process { running: true; command: ["mkdir", "-p", root.dir] }
    FileView {
        id: file
        path: root.dir + "/activity.json"
        printErrors: false
        onLoaded: { try { root.data = JSON.parse(text()); root.rev++ } catch (e) {} }
    }
}
