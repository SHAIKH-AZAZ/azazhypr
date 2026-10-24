pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Clipboard history backed by cliphist. wl-paste feeds every copy into it
// while clipboardEnabled is set. Images are decoded once into a private cache
// in the runtime directory (in memory) so they can be shown.
QtObject {
    id: root

    readonly property int maxItems: 40
    readonly property string cacheDir: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/latto-clipboard"

    // [{ id, text, image, format, size, width, height }], newest first;
    // image is "" for text.
    property var items: []
    // Cached image file names, set once decoding finishes.
    property var decoded: ({})

    // The image entry hovered in the Clipboard tab, previewed beside the island.
    property var previewItem: null

    function isId(id) {
        return /^\d+$/.test(id);
    }

    function refresh() {
        if (Settings.clipboardEnabled)
            listing.running = true;
    }

    function copy(id) {
        if (isId(id))
            run("cliphist decode " + id + " | wl-copy");
    }

    function remove(id) {
        if (isId(id))
            run("cliphist list | awk -F '\\t' '$1 == \"" + id + "\"' | cliphist delete");
    }

    function clear() {
        run("cliphist wipe");
    }

    function run(script) {
        action.command = ["sh", "-c", script];
        action.running = true;
    }

    function imageUrl(item) {
        return item.image && decoded[item.id + "." + item.format] ? "file://" + item.image : "";
    }

    function parse(text) {
        return text.split("\n")
            .filter(line => line.length > 0)
            .slice(0, maxItems)
            .map(line => {
                const tab = line.indexOf("\t");
                const id = line.slice(0, tab);
                const preview = line.slice(tab + 1);
                // cliphist lists images as "[[ binary data 2 MiB png 1920×1080 ]]".
                const m = preview.match(/^\[\[ binary data (.+) (\w+) (\d+)[x×](\d+) \]\]$/);
                return m
                    ? { id: id, text: preview, image: root.cacheDir + "/" + id + "." + m[2], format: m[2], size: m[1], width: +m[3], height: +m[4] }
                    : { id: id, text: preview, image: "" };
            })
            .filter(item => isId(item.id));
    }

    onItemsChanged: {
        const files = items.filter(item => item.image).map(item => item.id + "." + item.format);
        if (files.join(" ") === decoder.files.join(" "))
            return;
        decoder.files = files;
        if (!decoder.running)
            decoder.start();
    }

    property Process watcher: Process {
        running: Settings.clipboardEnabled
        command: ["wl-paste", "--watch", "cliphist", "store"]
    }

    // Only a changed listing replaces items, so the list keeps its scroll.
    property Process listing: Process {
        property string last: ""

        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text === root.listing.last)
                    return;
                root.listing.last = this.text;
                root.items = root.parse(this.text);
            }
        }
    }

    // Brings the cache in line with the listed images: decodes new ones,
    // removes the rest. Names are "<id>.<format>", checked by parse().
    property Process decoder: Process {
        property var files: []
        property var decodingFiles: []

        function start() {
            decodingFiles = files;
            command = ["sh", "-c", "d=$1; shift; mkdir -p \"$d\" && chmod 700 \"$d\" && cd \"$d\" || exit 1; "
                + "for f in *; do case \" $* \" in *\" $f \"*) ;; *) rm -f -- \"$f\" ;; esac; done; "
                + "for f in \"$@\"; do [ -s \"$f\" ] || cliphist decode \"${f%%.*}\" > \"$f\"; done",
                "sh", root.cacheDir].concat(files);
            running = true;
        }

        onExited: {
            const done = {};
            for (const f of decodingFiles)
                done[f] = true;
            root.decoded = done;
            // The list changed while decoding; catch up.
            if (files.join(" ") !== decodingFiles.join(" "))
                start();
        }
    }

    property Process action: Process {}

    property Timer timer: Timer {
        interval: 2000
        running: Settings.clipboardEnabled
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
