import QtQuick
import "../components"
import "../services"

// click: mixer, middle-click: mute, scroll: gain
Btn {
    property var bar
    glyph: Sys.source?.muted ? "\uf131" : "\uf130"
    color: Sys.source?.muted ? Theme.muted : Theme.red
    onClicked: (item, b) => {
        if (b === Qt.MiddleButton && Sys.source) Sys.source.muted = !Sys.source.muted;
        else bar.toggle("audio", item);
    }
    onScrolled: d => Sys.setVol(Sys.source, (Sys.source?.volume ?? 0) + d * 0.05)
}
