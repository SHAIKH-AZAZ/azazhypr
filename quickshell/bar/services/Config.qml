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
    readonly property int notifRadius: 4              // corner radius of popups/cards (0 = boxy, 12 = soft)
    readonly property int notifCriticalTimeout: 10000 // ms a critical popup stays (0 = until dismissed). It stays in the panel either way
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

    // ---- activity (focus tracker) ----
    readonly property bool showActivity: true         // track focused-app time, bar button + panel
    readonly property int activityIdleSec: 120        // no input for this long = not counted
    readonly property int activityTickSec: 5          // sampling interval

    // ---- wallpaper picker ----
    readonly property bool wallpaperDissolve: true    // noise dissolve between wallpapers (shaders/dissolve.frag)
    readonly property int wallpaperFxMs: 600          // length of the dissolve

    // ---- calendar ----
    readonly property bool calendarMondayFirst: false // week starts on Monday instead of Sunday

    // ---- launcher / screenshot ----
    readonly property string terminal: "kitty"
    readonly property string screenshotScript: Quickshell.env("HOME") + "/.config/hypr/scripts/ScreenShot.sh"
}
