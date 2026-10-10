import QtQuick
import "../components"
import "../services"

Btn {
    glyph: "\uf011"
    color: Theme.red
    onClicked: Sys.run("wlogout")
}
