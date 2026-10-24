import QtQuick
import "../theme"

// A rounded text field with a placeholder.
Rectangle {
    id: field

    property alias input: input
    property string placeholder: ""
    property bool secret: false

    height: 26
    radius: 8
    color: Theme.island
    border.color: input.activeFocus ? Theme.blue : Theme.border
    border.width: 1

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        verticalAlignment: TextInput.AlignVCenter
        echoMode: field.secret ? TextInput.Password : TextInput.Normal
        passwordCharacter: "\u2022"
        color: Theme.text
        selectionColor: Theme.blue
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSmall + 1
        clip: true

        Label {
            anchors.verticalCenter: parent.verticalCenter
            visible: input.text === ""
            text: field.placeholder
            color: Theme.textTertiary
            font.pixelSize: Theme.fontSmall + 1
        }
    }
}
