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
    property bool paused: false                    // settings (persisted under "__settings")
    property int idleSec: Config.activityIdleSec
    property double lastTick: 0
    readonly property string today: Qt.formatDate(clock.date ?? new Date(), "yyyy-MM-dd")

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
    // a session = a stretch of activity; a new one starts after a gap longer than the idle timeout
    function sessions(k) { void rev; return (data.__sessions ?? {})[k] ?? 0 }
    function dayKeys() { return Object.keys(data).filter(k => /^\d{4}-\d{2}-\d{2}$/.test(k)) }

    property var _icons: ({})
    function icon(cls) {
        if (_icons[cls] !== undefined) return _icons[cls];
        const e = DesktopEntries.heuristicLookup(cls);
        const p = Quickshell.iconPath(e ? e.icon : cls.toLowerCase(), true) ?? "";
        _icons[cls] = p;
        return p;
    }
    function setPaused(v) { paused = v; save() }
    function setIdle(sec) { idleSec = Math.max(30, Math.min(900, sec)); save() }
    function resetToday() {
        const k = key(new Date());
        delete data[k];
        if (data.__sessions) delete data.__sessions[k];
        rev++;
        save();
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
        return last.split(" ").map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(" ");
    }

    function count(app) {
        if (!app || paused) return;
        const k = key(new Date());
        const now = Date.now();
        if (now - lastTick > idleSec * 1000) {
            const s = data.__sessions ?? (data.__sessions = {});
            s[k] = (s[k] ?? 0) + 1;
        }
        lastTick = now;
        const d = data[k] ?? (data[k] = {});
        d[app] = (d[app] ?? 0) + Config.activityTickSec;
        rev++;
        dirty = true;
    }
    function save() {
        data.__settings = { paused: paused, idleSec: idleSec };
        file.setText(JSON.stringify(data));
        dirty = false;
    }

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
        enabled: Config.showActivity && !root.paused
        timeout: root.idleSec
        respectInhibitors: true         // watching a video does not count as idle
        onIsIdleChanged: root.idle = isIdle
    }

    Process { running: true; command: ["mkdir", "-p", root.dir] }
    FileView {
        id: file
        path: root.dir + "/activity.json"
        printErrors: false
        onLoaded: {
            try {
                root.data = JSON.parse(text());
                const st = root.data.__settings;
                if (st) { root.paused = !!st.paused; if (st.idleSec) root.idleSec = st.idleSec }
                root.rev++;
            } catch (e) {}
        }
    }
}
