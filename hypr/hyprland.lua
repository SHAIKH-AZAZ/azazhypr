------------------------------------------------------------
--  JaKooLit Hyprland - Lua Entry Point
--  https://github.com/JaKooLit
--  https://wiki.hypr.land/
------------------------------------------------------------

------------------------------------------------------------
-- Initial Boot
------------------------------------------------------------

require("initial_boot")

------------------------------------------------------------
-- Default Configuration
------------------------------------------------------------

require("configs.Keybinds")
require("configs.Startup_Apps")
require("configs.ENVariables")
require("configs.Laptops")
require("configs.WindowRules")
require("configs.SystemSettings")

------------------------------------------------------------
-- User Overrides
------------------------------------------------------------

require("UserConfigs.Hypridle") -- emits ~/.config/hypr/hypridle.conf
require("UserConfigs.Startup_Apps")
require("UserConfigs.ENVariables")
require("UserConfigs.Laptops")
require("UserConfigs.LaptopDisplay")
require("UserConfigs.WindowRules")

require("UserConfigs.UserDecorations")
require("UserConfigs.UserAnimations")
require("UserConfigs.UserKeybinds")
require("UserConfigs.UserSettings")
require("UserConfigs.01-UserDefaults")

------------------------------------------------------------
-- Monitors & Workspaces
------------------------------------------------------------

require("monitors")
require("workspaces")

------------------------------------------------------------
-- Plugins
------------------------------------------------------------

-- Scroll Overview
-- Enable once installed and ABI matches.

-- require("plugins.scrolloverview")
require("plugins.scrolloverview")

------------------------------------------------------------
-- Optional Extras
------------------------------------------------------------

-- require("configs.Input")
-- require("configs.Gestures")
-- require("configs.Groups")
-- require("configs.Decorations")
-- require("configs.Animations")
-- require("configs.Misc")

-- HyprMod managed settings
require("hyprland-gui")
