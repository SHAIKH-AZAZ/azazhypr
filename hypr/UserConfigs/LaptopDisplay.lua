-- NOTE: this file is used for disabling the laptop display when closing the
-- lid. See the notes in UserConfigs/Laptops.lua.
--
-- The lid binds in Laptops.lua rewrite this file, so keep the generated line
-- on its own and in the exact shape they write.
---@diagnostic disable: undefined-global

hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
