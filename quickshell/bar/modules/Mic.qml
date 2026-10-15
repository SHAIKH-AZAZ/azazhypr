import QtQuick
import "../components"
import "../services"

// Microphone. Muted = dim slashed mic with a red strike-through.
// click: mixer, middle-click: mute, scroll: gain
Btn {
    property var bar
    readonly property bool off: Sys.source?.muted ?? false

    glyph: off ? "mic_off" : "mic"
    color: off ? Theme.red : Theme.fg
    pop: off
    onClicked: (item, b) => {
        if (b === Qt.MiddleButton && Sys.source) Sys.source.muted = !Sys.source.muted;
        else bar.toggle("audio", item);
    }
    onScrolled: d => Sys.setVol(Sys.source, (Sys.source?.volume ?? 0) + d * 0.05)
}
