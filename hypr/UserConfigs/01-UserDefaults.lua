-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
-- Your own default apps, default search engine etc.
--
-- The values are still stored in 01-UserDefaults.conf because
-- WaybarScripts.sh, RofiSearch.sh and Kool_Quick_Settings.sh parse that file
-- directly. Edit them there (or via SUPER SHIFT E) and they apply to both.
---@diagnostic disable: undefined-global

local home = assert(os.getenv("HOME"), "HOME environment variable is not set")

local vars = require("hyprvars").read(home .. "/.config/hypr/UserConfigs/01-UserDefaults.conf")

-- Default editor. Keep in sync with `env = EDITOR,...` in 01-UserDefaults.conf.
hl.env("EDITOR", "nvim")

return {
    -- Terminal and file manager, used by configs/Keybinds.lua.
    term = vars.term or "kitty",
    files = vars.files or "thunar",

    -- Preferred text editor for the KooL Quick Settings Menu (SUPER SHIFT E).
    edit = os.getenv("EDITOR") or "nano",

    -- Default search engine for ROFI Search (SUPER S).
    search_engine = vars.Search_Engine or "https://www.google.com/search?q={}",
}
