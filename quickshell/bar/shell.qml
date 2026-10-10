//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import "windows"
import "services"

// Entry point. Run with: qs -c bar
//
//   services/    singletons: Theme (palette), Sys (state + actions), Notifs (daemon)
//   components/  small reusable widgets: Btn, Txt, Chip, Slide, ListRow, Pill
//   modules/     one file per bar module (Clock, Workspaces, Volume, ...)
//   panels/      dropdown contents, one file per module that opens one
//   windows/     layer-shell windows: Bar, Dropdown, NotifPopups, Osd, Launcher, Screenshot, Clipboard, Wallpaper
//   scripts/     shell helpers called by services/Sys.qml
//
// Launcher: qs -p ~/.config/quickshell/bar ipc call launcher toggle   (bind to Super+D)
ShellRoot {
    Variants {
        model: Quickshell.screens
        Bar {}
    }
    NotifPopups {}
    Osd {}
    Launcher {}
    Screenshot {}
    Clipboard {}
    Wallpaper {}

    // qs -p <bar> ipc call bar toggle
    IpcHandler {
        target: "bar"
        function toggle(): void { Sys.barHidden = !Sys.barHidden }
    }
}
