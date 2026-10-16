import QtQuick
import "../services"
import Quickshell
import Quickshell.Io

// Idle = flat dotted line. cava only runs while something is playing.
Row {
    id: root
    property var vals: []
    property int bars: 22
    spacing: 2

    Repeater {
        model: root.bars
        Rectangle {
            required property int index
            anchors.verticalCenter: parent.verticalCenter
            width: 3
            height: Math.max(2, (root.vals[index] ?? 0) / 100 * 24)
            radius: 1
            color: Theme.accent
            Behavior on height { NumberAnimation { duration: 60 } }
        }
    }

    Process {
        running: Sys.playing && root.visible
        command: ["cava", "-p", Quickshell.shellPath("cava.conf")]
        stdout: SplitParser { onRead: l => root.vals = l.split(";").map(Number) }
        onRunningChanged: if (!running) root.vals = []
    }
}
