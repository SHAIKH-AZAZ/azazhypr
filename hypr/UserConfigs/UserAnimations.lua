-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
-- Animations - https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
--
-- NOTE: the animation picker (SUPER SHIFT A, scripts/Animations.sh) overwrites
-- this file with a preset from animations/*.conf, converted to Lua by
-- scripts/AnimConfToLua.awk. Hand edits survive until the next pick, and the
-- file it replaces is kept as UserAnimations.lua.bak.
---@diagnostic disable: undefined-global

hl.config({
    animations = {
        enabled = true,
    },
})

------------------------------------------------------------
-- Curves
------------------------------------------------------------

hl.curve("wind",      { type = "bezier", points = { { 0.05, 0.9 },  { 0.1, 1.05 } } })
hl.curve("winIn",     { type = "bezier", points = { { 0.1, 1.1 },   { 0.1, 1.1 } } })
hl.curve("winOut",    { type = "bezier", points = { { 0.3, -0.3 },  { 0, 1 } } })
hl.curve("liner",     { type = "bezier", points = { { 1, 1 },       { 1, 1 } } })
hl.curve("overshot",  { type = "bezier", points = { { 0.05, 0.9 },  { 0.1, 1.05 } } })
hl.curve("smoothOut", { type = "bezier", points = { { 0.5, 0 },     { 0.99, 0.99 } } })
hl.curve("smoothIn",  { type = "bezier", points = { { 0.5, -0.5 },  { 0.68, 1.5 } } })

------------------------------------------------------------
-- Animations
------------------------------------------------------------

hl.animation({ leaf = "windows",       enabled = true, speed = 6,   bezier = "wind",      style = "slide" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 5,   bezier = "winIn",     style = "slide" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 3,   bezier = "smoothOut", style = "slide" })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 5,   bezier = "wind",      style = "slide" })
hl.animation({ leaf = "border",        enabled = true, speed = 1,   bezier = "liner" })

-- used by rainbow borders and rotating colors.
-- The .conf used speed 180; the Lua API caps animation speed at 100, so the
-- border rotates ~1.8x faster than it did before.
hl.animation({ leaf = "borderangle",   enabled = true, speed = 100, bezier = "liner",     style = "loop" })

hl.animation({ leaf = "fade",          enabled = true, speed = 3,   bezier = "smoothOut" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 5,   bezier = "overshot" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 5,   bezier = "winIn",     style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 5,   bezier = "winOut",    style = "slide" })
