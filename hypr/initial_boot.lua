-- First-run setup, ported from `exec-once = $HOME/.config/hypr/initial-boot.sh`.
-- The script no-ops once ~/.config/hypr/.initial_startup_done exists.
---@diagnostic disable: undefined-global

local home = assert(os.getenv("HOME"), "HOME environment variable is not set")

hl.on("hyprland.start", function()
    hl.exec_cmd(home .. "/.config/hypr/initial-boot.sh")
end)
