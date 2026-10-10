pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Small per-day notes/events for the calendar panel. Stored as JSON, kept out of the dotfiles:
//   ~/.local/share/quickshell-bar/events.json   { "2026-10-14": ["Dentist 5pm", ...] }
Singleton {
    id: root

    readonly property string dir: Quickshell.env("HOME") + "/.local/share/quickshell-bar"
    property var data: ({})

    function key(d) { return Qt.formatDate(d, "yyyy-MM-dd") }
    function on(d) { return data[key(d)] ?? [] }
    function add(d, text) {
        const t = text.trim();
        if (!t) return;
        const o = Object.assign({}, data), k = key(d);
        o[k] = [...(o[k] ?? []), t];
        data = o;
        save();
    }
    function remove(d, i) {
        const o = Object.assign({}, data), k = key(d);
        const l = (o[k] ?? []).filter((_, j) => j !== i);
        if (l.length) o[k] = l; else delete o[k];
        data = o;
        save();
    }
    function save() { file.setText(JSON.stringify(data, null, 1)) }

    Process { running: true; command: ["mkdir", "-p", root.dir] }
    FileView {
        id: file
        path: root.dir + "/events.json"
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: { try { root.data = JSON.parse(text()) } catch (e) {} }
    }
}
