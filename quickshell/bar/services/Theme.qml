pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Wallpaper palette. wallust rewrites qml_color.json (template:
// ~/.config/wallust/templates/qml_color.json) on every wallpaper change.
Singleton {
    id: root

    property var c: ({})

    FileView {
        path: Quickshell.env("HOME") + "/.config/quickshell/qml_color.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try { root.c = JSON.parse(text()) } catch (e) {}
        }
    }

    readonly property color bg: c.background ?? "#1e1e2e"
    readonly property color fg: c.color7 ?? "#cdd6f4"
    readonly property color muted: c.color8 ?? "#a6adc8"
    readonly property color subtle: c.color0 ?? "#45475a"
    readonly property color accent: c.color6 ?? "#89dceb"
    readonly property color blue: c.color6 ?? "#89dceb"      // wayle blue  -> color6
    readonly property color green: c.color4 ?? "#a6e3a1"     // wayle green -> color4
    readonly property color yellow: c.color5 ?? "#f9e2af"    // wayle yellow-> color5
    readonly property color red: c.color3 ?? "#f38ba8"       // wayle red   -> color3
    readonly property string font: "JetBrainsMono Nerd Font"
}
