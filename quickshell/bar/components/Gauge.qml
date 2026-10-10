import QtQuick
import "../services"

// Circular gauge: value 0..1, centered text, caption underneath.
Item {
    id: root
    property real value: 0
    property string text
    property string caption
    property color color: Theme.accent

    implicitWidth: 60
    implicitHeight: 82

    onValueChanged: ring.requestPaint()
    onColorChanged: ring.requestPaint()

    Canvas {
        id: ring
        width: 52; height: 52
        anchors.horizontalCenter: parent.horizontalCenter
        onPaint: {
            const c = getContext("2d");
            c.reset();
            c.lineWidth = 4;
            c.lineCap = "round";
            const cx = width / 2, cy = height / 2, r = width / 2 - 4;
            c.strokeStyle = Theme.subtle;
            c.beginPath(); c.arc(cx, cy, r, 0, Math.PI * 2); c.stroke();
            const v = Math.max(0, Math.min(1, root.value));
            if (v > 0) {
                c.strokeStyle = root.color;
                c.beginPath();
                c.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * v);
                c.stroke();
            }
        }
        Text {
            anchors.centerIn: parent
            text: root.text
            color: Theme.fg
            font { family: Theme.font; pixelSize: 12 }
        }
    }
    Text {
        anchors { horizontalCenter: parent.horizontalCenter; top: ring.bottom; topMargin: 6 }
        text: root.caption
        color: Theme.muted
        font { family: Theme.font; pixelSize: 11 }
    }
}
