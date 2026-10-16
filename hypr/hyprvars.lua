-- Reads hyprlang "$name = value" declarations out of a .conf file.
--
-- Some .conf files are still written by other tools and cannot simply be
-- converted: wallust regenerates wallust/wallust-hyprland.conf, and the KooL
-- shell scripts (WaybarScripts.sh, RofiSearch.sh, Kool_Quick_Settings.sh)
-- parse UserConfigs/01-UserDefaults.conf. Reading them here keeps one source
-- of truth instead of duplicating the values into Lua.

local M = {}

---@param path string
---@return table<string, string>
function M.read(path)
    local vars = {}

    local file = io.open(path, "r")
    if not file then
        return vars
    end

    for line in file:lines() do
        local name, value = line:match("^%s*%$([%w_]+)%s*=%s*(.-)%s*$")
        if name then
            value = value:gsub("%s+#.*$", "")     -- trailing comment
            value = value:gsub('^"(.*)"$', "%1")  -- surrounding quotes
            vars[name] = value
        end
    end

    file:close()
    return vars
end

return M
