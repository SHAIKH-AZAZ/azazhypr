import QtQuick
import "../components"
import "../services"

Btn {
    glyph: "power_settings_new"
    color: Theme.red
    onClicked: Sys.run("wlogout")
}
