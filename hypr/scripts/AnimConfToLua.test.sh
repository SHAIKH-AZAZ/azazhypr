#!/usr/bin/env bash
# Self-check for AnimConfToLua.awk. Converts every preset in animations/ and
# asserts the output is valid Lua, plus the conversions that are easy to break.
#
#   ./scripts/AnimConfToLua.test.sh

set -uo pipefail

scriptsDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
awkScript="$scriptsDir/AnimConfToLua.awk"
animDir="$(dirname "$scriptsDir")/animations"
fails=0

fail() { echo "FAIL: $*"; fails=$((fails + 1)); }

convert() { awk -f "$awkScript" "$1"; }

# Every preset must convert to syntactically valid Lua.
shopt -s nullglob
presets=("$animDir"/*.conf)
# Guard against a wrong animDir turning the loop below into a vacuous pass.
[ "${#presets[@]}" -gt 0 ] || fail "no presets found in $animDir"
for preset in "${presets[@]}"; do
    out=$(convert "$preset")
    if ! printf '%s\n' "$out" | luac -p - 2>/dev/null; then
        fail "$(basename "$preset"): output is not valid Lua"
    fi
    if grep -q '^-- skipped' <<<"$out"; then
        fail "$(basename "$preset"): $(grep '^-- skipped' <<<"$out")"
    fi
done

# Speed above the hl.animation maximum must be clamped, not passed through.
# Hyprland rejects the whole leaf otherwise and leaves it disabled.
out=$(convert "$animDir/00-default.conf")
grep -q 'leaf = "borderangle", enabled = true, speed = 100,' <<<"$out" \
    || fail "borderangle speed 180 was not clamped to 100"
grep -q 'speed = 180' <<<"$out" && fail "unclamped speed 180 leaked into output"

# `animation = border, 0` is the off shorthand: no speed, no curve.
out=$(convert "$animDir/HYDE - Vertical.conf")
grep -qx 'hl.animation({ leaf = "border", enabled = false })' <<<"$out" \
    || fail "off shorthand 'animation = border, 0' not converted"
# Styles carrying a percentage must survive as one string.
grep -q 'style = "slidefadevert 30%"' <<<"$out" \
    || fail "percentage style was mangled"

# `enabled = no` on the animations block must disable animations.
out=$(convert "$animDir/03- Disable Animation.conf")
grep -qx 'hl.config({ animations = { enabled = false } })' <<<"$out" \
    || fail "animations.enabled = no not converted"

# Inline '#' comments must not end up inside a value.
out=$(convert "$animDir/01-default - v2.conf")
grep -q '#' <<<"$out" && fail "inline comment leaked into output"
# Bezier y is limited to [-1, 2]; out-of-range points make Hyprland drop the
# whole curve, so both ends must be clamped. x has no limit and must not move.
grep -q 'hl.curve("nice", { type = "bezier", points = { { 0, 2 }, { 0.5, -1 } } })' <<<"$out" \
    || fail "out-of-range bezier y was not clamped to [-1, 2]"
grep -q 'hl.curve("bounce", { type = "bezier", points = { { 1.1, 1.6 }, { 0.1, 0.85 } } })' <<<"$out" \
    || fail "in-range bezier points were altered (x > 1 is legal)"

if [ "$fails" -eq 0 ]; then
    echo "ok: all presets convert to valid Lua"
else
    echo "$fails check(s) failed"
    exit 1
fi
