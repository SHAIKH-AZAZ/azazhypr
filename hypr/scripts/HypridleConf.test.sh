#!/usr/bin/env bash
# Self-check for UserConfigs/Hypridle.lua -- renders the config and asserts the
# lock listener is present with the expected timeout.
set -euo pipefail

cd "$(dirname "$0")/.."

lua - <<'LUA'
package.path = "./?.lua;" .. package.path
local H = require("UserConfigs.Hypridle")
local conf = H.render()

assert(conf:match("lock_cmd = pidof hyprlock"), "missing lock_cmd")
assert(conf:match("on%-timeout = loginctl lock%-session"), "missing lock listener")

-- the lock listener's timeout must match the configured value
local lock
for _, l in ipairs(H.listeners) do
  if l.on_timeout == "loginctl lock-session" then lock = l end
end
assert(lock, "no lock listener defined")
assert(conf:match("timeout = " .. lock.timeout), "lock timeout not emitted")
assert(lock.timeout == 10800, "expected 3h lock timeout, got " .. lock.timeout)

-- warning must fire before the lock, not after
for _, l in ipairs(H.listeners) do
  if l ~= lock then assert(l.timeout < lock.timeout, l.name .. " fires after lock") end
end

print("ok: lock timeout " .. lock.timeout .. "s (" .. lock.timeout / 3600 .. "h)")
LUA
