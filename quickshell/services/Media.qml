pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// The most relevant MPRIS player (a playing one first, otherwise any) and its controls.
QtObject {
    id: root

    readonly property var player: {
        let fallback = null;
        for (const candidate of Mpris.players.values) {
            if (candidate.isPlaying)
                return candidate;
            if (!fallback)
                fallback = candidate;
        }
        return fallback;
    }

    readonly property bool playing: player ? player.isPlaying : false
    readonly property string title: player ? (player.trackTitle || "Unknown title") : ""
    readonly property string artist: player ? player.trackArtist : ""
    readonly property string album: player ? player.trackAlbum : ""
    readonly property string art: player ? player.trackArtUrl : ""
    readonly property string source: player ? player.identity : ""
    readonly property real length: player && player.lengthSupported ? player.length : 0
    readonly property bool shuffle: player ? player.shuffle : false
    readonly property bool shuffleSupported: player ? player.shuffleSupported : false
    readonly property int loopState: player ? player.loopState : MprisLoopState.None
    readonly property bool loopSupported: player ? player.loopSupported : false
    readonly property bool looping: loopState !== MprisLoopState.None
    readonly property bool loopingTrack: loopState === MprisLoopState.Track
    readonly property bool canSeek: player ? player.canSeek : false

    // Seconds. MPRIS does not push position updates, so refreshPosition() polls.
    property real position: 0
    readonly property real progress: length > 0 ? Math.min(1, position / length) : 0

    onTitleChanged: refreshPosition()

    function refreshPosition() {
        if (!player)
            return;
        player.positionChanged();
        position = player.position;
    }

    property Timer positionTimer: Timer {
        interval: 500
        repeat: true
        running: root.playing
        triggeredOnStart: true
        onTriggered: root.refreshPosition()
    }

    // Brings the player's window, or the browser tab that is playing, to the
    // front. MPRIS raise is skipped: browsers don't offer it, and Hyprland
    // doesn't follow it for the players that do.
    function raise() {
        if (player)
            Quickshell.execDetached(["sh", Quickshell.shellDir + "/services/scripts/focus-player.sh", player.dbusName, player.trackTitle]);
    }

    function toggle() {
        if (player && player.canTogglePlaying)
            player.togglePlaying();
    }

    function next() {
        if (player && player.canGoNext)
            player.next();
    }

    function previous() {
        if (player && player.canGoPrevious)
            player.previous();
    }

    // fraction is 0..1 along the track.
    function seek(fraction) {
        if (player && player.canSeek && length > 0) {
            player.position = Math.max(0, Math.min(1, fraction)) * length;
            refreshPosition();
        }
    }

    function toggleShuffle() {
        if (player && player.shuffleSupported)
            player.shuffle = !player.shuffle;
    }

    // Off, then the whole list, then the one track.
    function cycleLoop() {
        if (!loopSupported)
            return;
        player.loopState = loopState === MprisLoopState.None ? MprisLoopState.Playlist
            : loopState === MprisLoopState.Playlist ? MprisLoopState.Track
            : MprisLoopState.None;
    }

    // Sets the position rather than calling seek(): browsers hand a relative
    // seek to the page, which may skip its own amount.
    function seekBy(seconds) {
        if (!canSeek)
            return;
        refreshPosition();
        const target = Math.max(0, position + seconds);
        player.position = length > 0 ? Math.min(length, target) : target;
        refreshPosition();
    }
}
