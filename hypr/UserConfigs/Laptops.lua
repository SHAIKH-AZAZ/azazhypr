-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
-- Mostly laptop related. Addendum to configs/Keybinds.lua.
-- See https://wiki.hypr.land/Configuring/Basics/Binds/#switches
---@diagnostic disable: undefined-global

local home = assert(os.getenv("HOME"), "HOME environment variable is not set")
local userConfigs = home .. "/.config/hypr/UserConfigs"

-- Useful when connecting your laptop to an external display.
-- From the wiki: this disables the laptop monitor when the lid is closed.
--
-- hl.bind("switch:off:Lid Switch",
--     hl.dsp.exec_cmd([[hyprctl keyword monitor "eDP-1, preferred, auto, 1"]]),
--     { locked = true })
-- hl.bind("switch:on:Lid Switch",
--     hl.dsp.exec_cmd([[hyprctl keyword monitor "eDP-1, disable"]]),
--     { locked = true })

-- WARNING! Using the method below has some caveats! USE WITH SOME CAUTION!
-- CONS: you need to set up your wallpaper again (SUPER W) and pick one.
-- CAVEAT: sometimes the main laptop monitor has no display and needs the
-- external monitor to be reconnected. One workaround is to make sure the lid
-- is OPEN before shutting the laptop down.
-- Make sure the `switch:` binds above stay commented out if you use these.
-- NOTE: the laptop display is written into LaptopDisplay.lua.
-- Use this if you do not want the main laptop monitor to wake up during e.g.
-- a wallpaper change.
--
-- local lidOpen = [[hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })]]
-- local lidClosed = [[hl.monitor({ output = "eDP-1", disabled = true })]]
--
-- hl.bind("switch:off:Lid Switch",
--     hl.dsp.exec_cmd(string.format("echo '%s' > %s/LaptopDisplay.lua", lidOpen, userConfigs)),
--     { locked = true })
-- hl.bind("switch:on:Lid Switch",
--     hl.dsp.exec_cmd(string.format("echo '%s' > %s/LaptopDisplay.lua", lidClosed, userConfigs)),
--     { locked = true })
--
-- for the laptop-lid action (to erase the last entry)
-- hl.on("hyprland.start", function()
--     hl.exec_cmd(string.format("echo '%s' > %s/LaptopDisplay.lua", lidOpen, userConfigs))
-- end)

-- ponytail: userConfigs is only referenced by the commented lid binds above.
local _ = userConfigs
