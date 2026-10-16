-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
-- Laptop-specific settings and keybinds.
-- https://wiki.hypr.land/Configuring/Basics/Binds/
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/
---@diagnostic disable: undefined-global


local home = assert(
    os.getenv("HOME"),
    "HOME environment variable is not available"
)

------------------------------------------------------------
-- Variables
------------------------------------------------------------

local mainMod = "SUPER"
local scriptsDir = home .. "/.config/hypr/scripts"

-- Run `hyprctl devices` to confirm the correct touchpad name.
local touchpadDevice = "asue1209:00-04f3:319f-touchpad"
local touchpadEnabled = true

------------------------------------------------------------
-- Keyboard brightness
------------------------------------------------------------

hl.bind(
    "XF86KbdBrightnessDown",
    hl.dsp.exec_cmd(scriptsDir .. "/BrightnessKbd.sh --dec"),
    {
        repeating = true,
        description = "Decrease keyboard brightness",
    }
)

hl.bind(
    "XF86KbdBrightnessUp",
    hl.dsp.exec_cmd(scriptsDir .. "/BrightnessKbd.sh --inc"),
    {
        repeating = true,
        description = "Increase keyboard brightness",
    }
)

------------------------------------------------------------
-- ASUS laptop controls
------------------------------------------------------------

hl.bind(
    "XF86Launch1",
    hl.dsp.exec_cmd("rog-control-center"),
    {
        description = "Open ASUS ROG Control Center",
    }
)

hl.bind(
    "XF86Launch3",
    hl.dsp.exec_cmd("asusctl led-mode -n"),
    {
        description = "Switch keyboard RGB profile",
    }
)

hl.bind(
    "XF86Launch4",
    hl.dsp.exec_cmd("asusctl profile -n"),
    {
        description = "Switch ASUS performance profile",
    }
)

------------------------------------------------------------
-- Display brightness
------------------------------------------------------------

hl.bind(
    "XF86MonBrightnessDown",
    hl.dsp.exec_cmd(scriptsDir .. "/Brightness.sh --dec"),
    {
        repeating = true,
        description = "Decrease display brightness",
    }
)

hl.bind(
    "XF86MonBrightnessUp",
    hl.dsp.exec_cmd(scriptsDir .. "/Brightness.sh --inc"),
    {
        repeating = true,
        description = "Increase display brightness",
    }
)

------------------------------------------------------------
-- Touchpad
------------------------------------------------------------

hl.bind(
    "XF86TouchpadToggle",
    hl.dsp.exec_cmd(scriptsDir .. "/TouchPad.sh"),
    {
        description = "Toggle touchpad",
    }
)

------------------------------------------------------------
-- Screenshots using F6
------------------------------------------------------------

hl.bind(
    mainMod .. " + F6",
    hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --now"),
    {
        description = "Take screenshot",
    }
)

hl.bind(
    mainMod .. " + SHIFT + F6",
    hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --area"),
    {
        description = "Take area screenshot",
    }
)

hl.bind(
    mainMod .. " + CTRL + F6",
    hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in5"),
    {
        description = "Take screenshot after 5 seconds",
    }
)

hl.bind(
    mainMod .. " + ALT + F6",
    hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in10"),
    {
        description = "Take screenshot after 10 seconds",
    }
)

hl.bind(
    "ALT + F6",
    hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --active"),
    {
        description = "Take active-window screenshot",
    }
)

------------------------------------------------------------
-- Touchpad device configuration
------------------------------------------------------------

hl.device({
    name = touchpadDevice,
    enabled = touchpadEnabled,
})
