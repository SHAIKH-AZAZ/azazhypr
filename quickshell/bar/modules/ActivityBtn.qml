import QtQuick
import "../components"
import "../services"

// Today's focused time -> activity panel
Btn {
    property var bar
    visible: Config.showActivity
    glyph: "timer"; size: 17
    color: Theme.green
    label: Activity.fmt(Activity.total(Activity.today))
    onClicked: item => bar.toggle("activity", item)
}
