import QtQuick
import Quickshell
import Quickshell.Wayland
import "../services"

// Wallpaper change effect: a full-screen window just above the wallpaper layer that shows the old
// image and dissolves it into the new one with shaders/dissolve.frag ("fast") or
// shaders/dissolve_rich.frag ("rich"), chosen by Config.wallpaperFxStyle.
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
    readonly property bool rich: Config.wallpaperFxStyle === "rich"
    property int customMs: 0            // run(..., ms) override for one transition
    readonly property int duration: customMs > 0 ? customMs : (rich ? Config.wallpaperFxRichMs : Config.wallpaperFxMs)
    property real dir: 1                // +1 / -1, drift direction of the rich style
    readonly property bool busy: shown

    signal started()

    property bool shown: false
    screen: Quickshell.screens.find(s => s.name === monitor) ?? Quickshell.screens[0]
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: shown
    mask: Region {}                     // never takes pointer input
    // Top = above windows (the effect is visible even with apps open, the picker stays above it);
    // Bottom = only visible on an empty desktop
    WlrLayershell.layer: Config.wallpaperFxOverWindows ? WlrLayer.Top : WlrLayer.Bottom
    WlrLayershell.namespace: "quickshell-wallpaperfx"

    function url(p) { return "file://" + encodeURI(p).replace(/#/g, "%23") }

    function run(from, to, ms, direction) {
        anim.stop();
        customMs = ms ?? 0;
        dir = direction ?? 1;
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

    Image { id: oldImg; visible: false; source: win.fromSrc ? win.url(win.fromSrc) : ""; fillMode: Image.PreserveAspectCrop; asynchronous: true; cache: false; sourceSize: Qt.size(win.width, win.height); onStatusChanged: win.check() }
    Image { id: newImg; visible: false; source: win.toSrc ? win.url(win.toSrc) : ""; fillMode: Image.PreserveAspectCrop; asynchronous: true; cache: false; sourceSize: Qt.size(win.width, win.height); onStatusChanged: win.check() }

    ShaderEffect {
        id: effect
        anchors.fill: parent
        property variant oldTex: oldImg
        property variant newTex: newImg
        property real progress: 0
        property real seed: 0
        property real aspect: width / Math.max(1, height)
        // rich-style tunables (ignored by the fast shader)
        property real scale: Config.wallpaperFxNoise
        property real direction: win.dir
        property real edge: Config.wallpaperFxEdge
        property real drift: Config.wallpaperFxDrift
        fragmentShader: Qt.resolvedUrl(win.rich ? "../shaders/dissolve_rich.frag.qsb" : "../shaders/dissolve.frag.qsb")
    }

    NumberAnimation {
        id: anim
        target: effect
        property: "progress"
        from: 0; to: 1
        duration: win.duration
        easing.type: win.rich ? Easing.InOutQuint : Easing.InOutSine
        onFinished: { win.animDone = true; win.hideIfDone() }
    }

    // safety: never leave the overlay up if the caller forgets to set `ready`
    Timer {
        interval: win.duration + 4000
        running: win.shown
        onTriggered: { win.ready = true; win.hideIfDone() }
    }
}
