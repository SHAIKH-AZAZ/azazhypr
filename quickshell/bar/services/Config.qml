pragma Singleton
import Quickshell

// Tweakables. Edit the values, the bar reloads on save.
Singleton {
    // ---- look ----
    // true = static ink-black surfaces (same as kitty's ink-black theme), false = wallpaper palette.
    // Accent colors (blue/green/yellow/red) always follow the wallpaper.
    readonly property bool inkBlack: true

    // ---- notifications ----
    readonly property int notifTimeout: 3000          // ms a popup stays when the app sets no timeout
    readonly property int notifMaxTimeout: 5000       // ms hard cap, even when the app asks for longer
    readonly property int notifMaxVisible: 4          // popups on screen at once
    readonly property bool notifCriticalSticky: true  // critical urgency stays until dismissed
    // brightness/volume scripts call notify-send; the OSD already shows those.
    // "hide" = swallow them (OSD only), "show" = also show a (replacing) popup
    readonly property string osdNotifs: "hide"

    // ---- OSD (volume / brightness bar) ----
    readonly property int osdTimeout: 1000            // ms visible after the last change

    // ---- bar modules ----
    readonly property bool showSystem: true           // cpu % + system panel
    readonly property bool showUpdates: true          // pending pacman updates (hidden at 0)
    readonly property bool showKbLayout: true         // only visible with 2+ layouts
    readonly property bool showWeather: true
    readonly property string weatherLocation: ""      // "" = auto by IP, or "Delhi", "28.6,77.2"
    readonly property int slowPollMs: 30 * 60 * 1000  // updates + weather refresh

    // ---- launcher / screenshot ----
    readonly property string terminal: "kitty"
    readonly property string screenshotScript: Quickshell.env("HOME") + "/.config/hypr/scripts/ScreenShot.sh"
}
