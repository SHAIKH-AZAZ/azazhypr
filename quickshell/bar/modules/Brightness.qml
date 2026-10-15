import QtQuick
import "../components"
import "../services"

Btn {
    property var bar
    glyph: "brightness_high"
    color: Theme.yellow
    onClicked: item => bar.toggle("brightness", item)
    onScrolled: d => Sys.setBright(Sys.bright + d * 5)
}
