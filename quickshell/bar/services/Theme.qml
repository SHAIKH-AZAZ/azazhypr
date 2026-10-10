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

    // inkBlack (Config): static ink-black + Snazzy accents (kitty-themes/ink-black.conf), ignores wallust.
    // Cards/borders need a lighter grey to show on #000.
    readonly property color bg: Config.inkBlack ? "#000000" : (c.background ?? "#1e1e2e")
    readonly property color fg: Config.inkBlack ? "#F1F1F0" : (c.color7 ?? "#cdd6f4")
    readonly property color muted: Config.inkBlack ? "#8a8a8a" : (c.color8 ?? "#a6adc8")
    readonly property color subtle: Config.inkBlack ? "#3a3a3c" : (c.color0 ?? "#45475a")
    readonly property color accent: Config.inkBlack ? "#9AEDFE" : (c.color6 ?? "#89dceb")
    readonly property color blue: Config.inkBlack ? "#57C7FF" : (c.color6 ?? "#89dceb")      // wayle blue  -> color6
    readonly property color green: Config.inkBlack ? "#5AF78E" : (c.color4 ?? "#a6e3a1")     // wayle green -> color4
    readonly property color yellow: Config.inkBlack ? "#F3F99D" : (c.color5 ?? "#f9e2af")    // wayle yellow-> color5
    readonly property color red: Config.inkBlack ? "#FF5C57" : (c.color3 ?? "#f38ba8")       // wayle red   -> color3
    readonly property string font: "JetBrainsMono Nerd Font"
}
