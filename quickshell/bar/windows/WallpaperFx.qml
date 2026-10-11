import QtQuick
import Quickshell
import Quickshell.Wayland

// Wallpaper change effect: a full-screen window just above the wallpaper layer that shows the old
// image and dissolves it into the new one with shaders/dissolve.frag (noise burn-through).
// awww is the real wallpaper underneath. Order of events (driven by windows/Wallpaper.qml):
//   run(old, new) -> textures load -> overlay appears (looks identical to the wallpaper) -> started()
//   -> caller sets the real wallpaper under it -> dissolve plays -> overlay hides once `ready` is set.
PanelWindow {
    id: win

    property string monitor: ""
    property string fromSrc: ""
    property string toSrc: ""
    property bool ready: false          // caller: the real wallpaper underneath is now the new one
    property bool animDone: false
    property int duration: 600
    readonly property bool busy: shown

    signal started()

    property bool shown: false
    screen: Quickshell.screens.find(s => s.name === monitor) ?? Quickshell.screens[0]
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: shown
    mask: Region {}                     // never takes pointer input
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "quickshell-wallpaperfx"

    function url(p) { return "file://" + encodeURI(p).replace(/#/g, "%23") }

    function run(from, to, ms) {
        anim.stop();
        duration = ms ?? duration;
        ready = false;
        animDone = false;
        pending = true;
        fromSrc = from;
        toSrc = to;
        effect.seed = Math.random() * 100;
        effect.progress = 0;
        check();
    }

    property bool pending: false
    function check() {
        if (!pending) return;
        const a = oldImg.status, b = newImg.status;
        if (a === Image.Error || b === Image.Error) {   // cannot dissolve: let the caller just switch
            pending = false;
            started();
            shown = false;
            return;
        }
        if (a !== Image.Ready || b !== Image.Ready) return;
        pending = false;
        shown = true;
        started();
        anim.restart();
    }
    function hideIfDone() { if (animDone && ready) { shown = false; fromSrc = ""; toSrc = "" } }
    onReadyChanged: hideIfDone()

    Image { id: oldImg; visible: false; source: win.fromSrc ? win.url(win.fromSrc) : ""; fillMode: Image.PreserveAspectCrop; asynchronous: true; onStatusChanged: win.check() }
    Image { id: newImg; visible: false; source: win.toSrc ? win.url(win.toSrc) : ""; fillMode: Image.PreserveAspectCrop; asynchronous: true; onStatusChanged: win.check() }

    ShaderEffect {
        id: effect
        anchors.fill: parent
        property variant oldTex: oldImg
        property variant newTex: newImg
        property real progress: 0
        property real seed: 0
        property real aspect: width / Math.max(1, height)
        fragmentShader: Qt.resolvedUrl("../shaders/dissolve.frag.qsb")
    }

    NumberAnimation {
        id: anim
        target: effect
        property: "progress"
        from: 0; to: 1
        duration: win.duration
        easing.type: Easing.InOutSine
        onFinished: { win.animDone = true; win.hideIfDone() }
    }

    // safety: never leave the overlay up if the caller forgets to set `ready`
    Timer {
        interval: win.duration + 4000
        running: win.shown
        onTriggered: { win.ready = true; win.hideIfDone() }
    }
}
