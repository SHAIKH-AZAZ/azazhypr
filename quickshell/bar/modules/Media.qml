import QtQuick
import "../components"
import "../services"

// Spinning disc. click: dropdown, right-click: play/pause, scroll: next/prev
Btn {
    property var bar
    glyph: "\uf192"; spin: Sys.playing
    color: Theme.blue
    onClicked: (item, b) => b === Qt.RightButton ? Sys.player?.togglePlaying() : bar.toggle("media", item)
    onScrolled: d => d > 0 ? Sys.player?.next() : Sys.player?.previous()
}
