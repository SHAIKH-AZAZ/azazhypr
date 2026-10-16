import QtQuick
import "../services"

// Arc carousel drawn by one fragment shader (shaders/molten.frag): the cards sit on a curve and
// fuse with their neighbours into one liquid shape, with a bridge between every pair.
// `model` = array of image paths, `index` = selected item. Emits picked(i) on a click on another
// card, activated() on a click on the selected one. Wheel / drag move the selection.
Item {
    id: root

    property var model: []
    property int index: 0
    property string thumbDir: ""            // folder of <md5(path)>.jpg thumbnails; "" = load originals
    signal picked(int i)
    signal activated()

    // geometry (px at scale 1)
    readonly property real cardW: 232
    readonly property real cardH: 140
    readonly property real gap: 14
    readonly property real spacing: Math.min(300, (width / 2 - 125) / 2)   // card-centre distance; shrinks so +-2 cards fit the width
    // motion melt: while the strip moves, `pos` lags `index`; that lag (0..1) pulls the cards
    // together and widens the smooth union so they fuse into strands, then they part again
    readonly property real melt: Math.min(1, Math.abs(index - pos))
    readonly property real fusion: 26 + 90 * melt   // bridge reach
    readonly property real sp: spacing * (1 - 0.18 * melt)

    // smooth position: follows `index` with easing, slots read it every frame
    property real pos: index
    Behavior on pos { NumberAnimation { duration: 420; easing.type: Easing.OutCubic } }

    // 7 slots as a ring buffer: slot j always shows the item index congruent to j (mod 7) inside
    // the window pos-3 .. pos+3, so a texture only changes while that card is off to the side.
    function slotIndex(j) {
        const base = Math.round(pos);
        let d = ((j - base) % 7 + 7) % 7;
        if (d > 3) d -= 7;
        return base + d;
    }
    function valid(j) { const i = slotIndex(j); return i >= 0 && i < model.length }
    // useOrig: this image failed to load as a thumbnail (not generated yet), use the original file
    function src(j, useOrig) {
        if (!valid(j)) return "";
        const p = model[slotIndex(j)];
        if (thumbDir && !useOrig) return "file://" + thumbDir + "/" + Qt.md5(p) + ".jpg";
        return "file://" + encodeURI(p).replace(/#/g, "%23");
    }
    function off(j) { return slotIndex(j) - pos }
    function scaleOf(o) { return 1.15 - 0.15 * Math.min(Math.abs(o), 3) }
    function xOf(o) {
        const a = Math.abs(o), s = o < 0 ? -1 : 1;
        return width / 2 + s * (a <= 1 ? a * sp : sp + (a - 1) * (sp - 22));
    }
    function yOf(o) { return height / 2 - 2 + 8 * o * o }
    function geom(j) {
        const o = off(j), s = scaleOf(o);
        return Qt.vector4d(xOf(o), yOf(o), cardW / 2 * s, cardH / 2 * s);
    }
    function misc(j) {
        const o = off(j), a = Math.abs(o);
        const alpha = valid(j) ? Math.max(0, Math.min(1, 1 - (a - 2.4) / 0.8)) : 0;
        return Qt.vector4d(o * 0.2, alpha, Math.max(0, 1 - a * 1.6), 0);
    }

    Image {
        id: img0
        visible: false
        asynchronous: true
        cache: true
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(464, 280)
        property bool useOrig: false
        property int forIdx: root.slotIndex(0)
        onForIdxChanged: useOrig = false
        onStatusChanged: if (status === Image.Error && !useOrig && root.thumbDir) useOrig = true
        source: root.src(0, useOrig)
    }
    Image {
        id: img1
        visible: false
        asynchronous: true
        cache: true
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(464, 280)
        property bool useOrig: false
        property int forIdx: root.slotIndex(1)
        onForIdxChanged: useOrig = false
        onStatusChanged: if (status === Image.Error && !useOrig && root.thumbDir) useOrig = true
        source: root.src(1, useOrig)
    }
    Image {
        id: img2
        visible: false
        asynchronous: true
        cache: true
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(464, 280)
        property bool useOrig: false
        property int forIdx: root.slotIndex(2)
        onForIdxChanged: useOrig = false
        onStatusChanged: if (status === Image.Error && !useOrig && root.thumbDir) useOrig = true
        source: root.src(2, useOrig)
    }
    Image {
        id: img3
        visible: false
        asynchronous: true
        cache: true
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(464, 280)
        property bool useOrig: false
        property int forIdx: root.slotIndex(3)
        onForIdxChanged: useOrig = false
        onStatusChanged: if (status === Image.Error && !useOrig && root.thumbDir) useOrig = true
        source: root.src(3, useOrig)
    }
    Image {
        id: img4
        visible: false
        asynchronous: true
        cache: true
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(464, 280)
        property bool useOrig: false
        property int forIdx: root.slotIndex(4)
        onForIdxChanged: useOrig = false
        onStatusChanged: if (status === Image.Error && !useOrig && root.thumbDir) useOrig = true
        source: root.src(4, useOrig)
    }
    Image {
        id: img5
        visible: false
        asynchronous: true
        cache: true
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(464, 280)
        property bool useOrig: false
        property int forIdx: root.slotIndex(5)
        onForIdxChanged: useOrig = false
        onStatusChanged: if (status === Image.Error && !useOrig && root.thumbDir) useOrig = true
        source: root.src(5, useOrig)
    }
    Image {
        id: img6
        visible: false
        asynchronous: true
        cache: true
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(464, 280)
        property bool useOrig: false
        property int forIdx: root.slotIndex(6)
        onForIdxChanged: useOrig = false
        onStatusChanged: if (status === Image.Error && !useOrig && root.thumbDir) useOrig = true
        source: root.src(6, useOrig)
    }

    ShaderEffect {
        anchors.fill: parent
        property vector2d res: Qt.vector2d(width, height)
        property real k: root.fusion
        property real cr: 16
        property color accent: Theme.accent
        property color base: Theme.subtle
        property vector4d g0: root.geom(0)
        property vector4d m0: root.misc(0)
        property variant t0: img0
        property vector4d g1: root.geom(1)
        property vector4d m1: root.misc(1)
        property variant t1: img1
        property vector4d g2: root.geom(2)
        property vector4d m2: root.misc(2)
        property variant t2: img2
        property vector4d g3: root.geom(3)
        property vector4d m3: root.misc(3)
        property variant t3: img3
        property vector4d g4: root.geom(4)
        property vector4d m4: root.misc(4)
        property variant t4: img4
        property vector4d g5: root.geom(5)
        property vector4d m5: root.misc(5)
        property variant t5: img5
        property vector4d g6: root.geom(6)
        property vector4d m6: root.misc(6)
        property variant t6: img6
        fragmentShader: Qt.resolvedUrl("../shaders/molten.frag.qsb")
    }

    // ---- input ----
    function nearestSlot(x) {
        let best = -1, bd = 1e9;
        for (let j = 0; j < 7; j++) {
            if (!valid(j)) continue;
            const dist = Math.abs(geom(j).x - x);
            if (dist < bd) { bd = dist; best = j }
        }
        return best;
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        property real pressX: 0
        property int pressIdx: 0
        property bool moved: false
        onPressed: e => { pressX = e.x; pressIdx = root.index; moved = false }
        onPositionChanged: e => {
            if (!pressed) return;
            if (Math.abs(e.x - pressX) > 8) moved = true;
            if (moved) {
                const i = Math.max(0, Math.min(root.model.length - 1, Math.round(pressIdx + (pressX - e.x) / root.spacing)));
                if (i !== root.index) root.picked(i);
            }
        }
        onReleased: e => {
            if (moved) return;
            const j = root.nearestSlot(e.x);
            if (j < 0) return;
            const i = root.slotIndex(j);
            if (i === root.index) root.activated(); else root.picked(i);
        }
        onWheel: e => {
            const d = (e.angleDelta.y < 0 || e.angleDelta.x < 0) ? 1 : -1;
            root.picked(Math.max(0, Math.min(root.model.length - 1, root.index + d)));
        }
    }
}
