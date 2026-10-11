import QtQuick
import "../components"
import "../services"

// Today's focused time -> activity panel
Btn {
    property var bar
    visible: Config.showActivity
    glyph: ""; size: 14
    color: Theme.green
    label: Activity.fmt(Activity.total(Activity.today))
    onClicked: item => bar.toggle("activity", item)
}
