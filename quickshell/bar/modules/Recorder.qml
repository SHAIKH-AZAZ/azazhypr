import QtQuick
import "../components"
import "../services"

// wf-recorder toggle, only shown while recording
Btn {
    glyph: "fiber_manual_record"
    visible: Sys.recording
    color: Theme.red
    onClicked: Sys.toggleRecord()
}
