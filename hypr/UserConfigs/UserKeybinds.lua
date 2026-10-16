-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
-- This is where you put your own keybinds. Also check configs/Keybinds.lua to
-- avoid conflicts.
--
-- See https://wiki.hypr.land/Configuring/Basics/Binds/ for more settings.
-- See also UserConfigs/Laptops.lua for laptop keybinds.
---@diagnostic disable: undefined-global

-- /* ---- ✴️ Variables ✴️ ---- */
local home = assert(os.getenv("HOME"), "HOME environment variable is not set")

local mainMod = "SUPER"
local scriptsDir = home .. "/.config/hypr/scripts"
local userScripts = home .. "/.config/hypr/UserScripts"

-- To remap an existing keybind, keep the handle configs/Keybinds.lua returns
-- and call :unbind() on it, or just rebind the key here — the last bind wins.
--
-- Bindings are CASE SENSITIVE. Include a description so the keybind search
-- menu shows it properly:
--
-- hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("APPNAME"), { description = "My z app" })

-- /* ---- ScrollOverview Plugin ---- */
-- Disabled: plugin not loaded (ABI mismatch - run: sudo chown -R azaz:azaz /var/cache/hyprpm/ && hyprpm update)
-- hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("hyprctl dispatch scrolloverview:overview toggle"),
--     { description = "Toggle workspace overview" })
-- hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd("hyprctl dispatch scrolloverview:overview select"),
--     { description = "Select hovered workspace" })

-- For passthrough keyboard into a VM
-- hl.define_submap("passthru", function()
--     hl.bind(mainMod .. " + ALT + P", hl.dsp.submap("reset"))
-- end)
-- hl.bind(mainMod .. " + ALT + P", hl.dsp.submap("passthru"))

-- ponytail: locals kept for the commented binds above.
local _ = { mainMod, scriptsDir, userScripts }
