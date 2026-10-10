import QtQuick
import "../components"
import "../services"

// click: mixer, middle-click: mute, scroll: volume
Btn {
    property var bar
    glyph: Sys.sink?.muted ? "\uf026" : "\uf028"
    color: Sys.sink?.muted ? Theme.muted : Theme.green
    onClicked: (item, b) => {
        if (b === Qt.MiddleButton && Sys.sink) Sys.sink.muted = !Sys.sink.muted;
        else bar.toggle("audio", item);
    }
    onScrolled: d => Sys.setVol(Sys.sink, (Sys.sink?.volume ?? 0) + d * 0.05)
}
