-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
-- For window rules and layer rules.
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
--
-- This file is used to add or overwrite window rules.
-- This file will not be modified during dotfiles updates.
---@diagnostic disable: undefined-global

-- Remove titlebar for Chrome
hl.window_rule({
    name = "chrome-no-decoration",
    match = { class = "^(google-chrome)$" },

    decorate = false,
})
