//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import "./modules/overview/"
import "./services/"
import "./modules/common/"
import "./modules/common/widgets/"

import QtQuick
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    Overview {}
}
