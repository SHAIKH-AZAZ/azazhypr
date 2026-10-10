import QtQuick
import QtQuick.Layouts
import "../services"

// Rounded section with an optional "GLYPH  TITLE" header. Children go in the body.
Rectangle {
    id: card
    property string title
    property string glyph
    default property alias content: body.data

    Layout.fillWidth: true
    implicitHeight: col.implicitHeight + 20
    radius: 12
    color: Qt.alpha(Theme.subtle, 0.45)

    ColumnLayout {
        id: col
        anchors { fill: parent; margins: 10 }
        spacing: 8

        RowLayout {
            visible: card.title !== ""
            spacing: 6
            Text { text: card.glyph; color: Theme.muted; font { family: Theme.font; pixelSize: 13 } }
            Text {
                text: card.title.toUpperCase()
                color: Theme.muted
                font { family: Theme.font; pixelSize: 11; letterSpacing: 1 }
            }
        }
        ColumnLayout { id: body; Layout.fillWidth: true; spacing: 8 }
    }
}
