-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
-- Hypridle config, defined in Lua and emitted to ~/.config/hypr/hypridle.conf
-- on every Hyprland config load. Edit the values here, NOT hypridle.conf.
---@diagnostic disable: undefined-global

local M = {}

-- /* ---- ⏱️ Timings (seconds) ⏱️ */
local LOCK_AFTER = 5 * 60 * 60 -- 3 hours
local WARN_BEFORE = 5 * 60 -- idle warning this long before the lock fires

local iDIR = "$iDIR"

M.vars = {
	{ "$iDIR", '"$HOME/.config/swaync/images/ja.png"' },
}

M.general = {
	-- runs hyprlock if it is not already running (always run on "loginctl lock-session")
	{ "lock_cmd", "pidof hyprlock || hyprlock" },
	-- ensures the session is locked before going to sleep
	{ "before_sleep_cmd", "loginctl lock-session" },
	-- turn the screen back on after sleep (not strictly necessary, but just in case)
	{ "after_sleep_cmd", "hyprctl dispatch dpms on" },
	-- whether to ignore dbus-sent idle-inhibit requests (used by e.g. firefox or steam)
	{ "ignore_dbus_inhibit", "false" },
}

M.listeners = {
	{
		name = "Idle warning",
		timeout = LOCK_AFTER - WARN_BEFORE,
		on_timeout = "notify-send -i " .. iDIR .. " ' You are idle!'",
		on_resume = "notify-send -i " .. iDIR .. " ' Oh! you are Back' ' Hello !!!'",
	},
	{
		name = "Screenlock",
		timeout = LOCK_AFTER,
		on_timeout = "loginctl lock-session",
	},

	-- Available but disabled by default. Uncomment to enable:
	--
	-- { name = "Screen off", timeout = LOCK_AFTER + 30,
	--   on_timeout = "hyprctl dispatch dpms off", on_resume = "hyprctl dispatch dpms on" },
	--
	-- { name = "Suspend", timeout = LOCK_AFTER + 600,
	--   on_timeout = "systemctl suspend" },
}

-- /* ---- 🛠️ Renderer 🛠️ */
function M.render()
	local out = {
		"# Generated from ~/.config/hypr/UserConfigs/Hypridle.lua -- do not edit by hand.",
		"",
	}

	for _, v in ipairs(M.vars) do
		table.insert(out, v[1] .. "=" .. v[2])
	end

	table.insert(out, "")
	table.insert(out, "general {")
	for _, kv in ipairs(M.general) do
		table.insert(out, "    " .. kv[1] .. " = " .. kv[2])
	end
	table.insert(out, "}")

	for _, l in ipairs(M.listeners) do
		table.insert(out, "")
		table.insert(out, "# " .. l.name .. " (" .. string.format("%.1f", l.timeout / 60) .. " min)")
		table.insert(out, "listener {")
		table.insert(out, "    timeout = " .. l.timeout)
		table.insert(out, "    on-timeout = " .. l.on_timeout)
		if l.on_resume then
			table.insert(out, "    on-resume = " .. l.on_resume)
		end
		table.insert(out, "}")
	end

	return table.concat(out, "\n") .. "\n"
end

function M.write(path)
	local home = assert(os.getenv("HOME"), "HOME environment variable is not set")
	path = path or (home .. "/.config/hypr/hypridle.conf")
	local file = assert(io.open(path, "w"))
	file:write(M.render())
	file:close()
	return path
end

-- Only emit when loaded by Hyprland; requiring this module from a test is side-effect free.
if rawget(_G, "hl") ~= nil then
	M.write()
end

return M
