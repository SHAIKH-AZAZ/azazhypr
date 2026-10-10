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
