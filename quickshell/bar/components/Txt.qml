import QtQuick
import QtQuick.Layouts
import "../services"

Text {
    color: Theme.fg
    elide: Text.ElideRight
    property bool icon: false           // text is a Material Symbols name ("wifi"), not words
    font { family: icon ? Theme.iconFont : Theme.font; pixelSize: 13 }
}
