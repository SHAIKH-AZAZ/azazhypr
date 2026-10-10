pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// Owns org.freedesktop.Notifications. Popups = recent subset of tracked.
Singleton {
    id: root

    readonly property string syncKey: "x-canonical-private-synchronous"

    property bool dnd: false
    property var popups: []
    property var counts: ({})         // notification id -> how many identical ones were merged into it
    property var times: ({})          // notification id -> arrival ms, for "5m" labels in the panel
    readonly property var list: server.trackedNotifications

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        actionsSupported: true
        imageSupported: true
        onNotification: n => {
            const tag = n.hints?.[root.syncKey] ?? "";

            // brightness/volume scripts: keep the OSD in sync, optionally swallow the popup
            if (tag === "brightness_notif" && n.hints.value !== undefined) Sys.bright = +n.hints.value;
            if ((tag === "brightness_notif" || tag === "volume_notif") && Config.osdNotifs === "hide") return;

            n.tracked = true;

            // identical (app, summary, body) as one already shown -> merge: old one goes, new one carries the count
            let count = 1;
            const same = x => x.appName === n.appName && x.summary === n.summary && x.body === n.body;
            for (const o of [...root.list.values]) {
                if (o !== n && same(o)) { count += root.counts[o.id] ?? 1; root.drop(o); o.dismiss(); }
            }

            const t = Object.assign({}, root.times);
            t[n.id] = Date.now();
            root.times = t;
            const c = Object.assign({}, root.counts);
            c[n.id] = count;
            root.counts = c;

            // "synchronous" tag = replace the previous notification with the same tag
            if (tag) {
                for (const o of [...root.list.values])
                    if (o !== n && o.hints?.[root.syncKey] === tag) { root.drop(o); o.dismiss(); }
            }

            if (!root.dnd) root.popups = [...root.popups, n];
        }
    }

    // qs -p <bar> ipc call notifs toggleDnd
    IpcHandler {
        target: "notifs"
        function toggleDnd(): void { root.dnd = !root.dnd }
        function clear(): void { root.clear() }
    }

    function drop(n) { popups = popups.filter(x => x !== n) }
    function clear() {
        popups = [];
        for (const n of [...list.values]) n.dismiss();
    }
}
