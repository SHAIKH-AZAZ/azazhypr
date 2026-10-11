import QtQuick
import "../components"
import "../services"

// Speaker. Icon follows the level; muted (or 0%) = dim speaker with a red strike-through.
// click: mixer, middle-click: mute, scroll: volume
Btn {
    property var bar
    readonly property real vol: Sys.sink?.volume ?? 0
    readonly property bool off: (Sys.sink?.muted ?? false) || vol < 0.005

    glyph: off ? "\uf026" : vol < 0.5 ? "\uf027" : "\uf028"
    color: off ? Theme.muted : Theme.green
    struck: off
    struckColor: Theme.red
    pop: off
    onClicked: (item, b) => {
        if (b === Qt.MiddleButton && Sys.sink) Sys.sink.muted = !Sys.sink.muted;
        else bar.toggle("audio", item);
    }
    onScrolled: d => Sys.setVol(Sys.sink, (Sys.sink?.volume ?? 0) + d * 0.05)
}
