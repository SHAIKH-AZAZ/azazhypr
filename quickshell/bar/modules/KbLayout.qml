import QtQuick
import "../components"
import "../services"

// Active keyboard layout, only shown when more than one is configured.
Btn {
    visible: Config.showKbLayout && Sys.kbMulti
    glyph: "keyboard"
    color: Theme.blue
    label: Sys.kbShort
}
