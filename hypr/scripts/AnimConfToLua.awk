#!/usr/bin/awk -f
# Convert a Hyprland animations/*.conf preset into Lua config syntax.
#
# Hyprland 0.56+ with configProvider=lua never reads .conf files, so the
# animation presets have to be translated before they can be applied.
#
#   awk -v preset="END-4" -f AnimConfToLua.awk animations/END-4.conf > UserAnimations.lua

function trim(s) {
    gsub(/^[ \t]+/, "", s)
    gsub(/[ \t]+$/, "", s)
    return s
}

function luastr(s) {
    gsub(/\\/, "\\\\", s)
    gsub(/"/, "\\\"", s)
    return "\"" s "\""
}

function isoff(s) {
    return (s == "0" || s == "no" || s == "false" || s == "off")
}

# Records into `clamped` whether the value had to be changed, so the caller can
# annotate the generated line.
function clamp(v, lo, hi) {
    clamped = 0
    if (v + 0 > hi) { clamped = 1; return hi }
    if (v + 0 < lo) { clamped = 1; return lo }
    return v
}

BEGIN {
    # Hyprland rejects out-of-range values outright rather than clamping them:
    # a bad speed drops the whole animation leaf and leaves it disabled, a bad
    # curve point drops the curve. Both raise a config-error banner. Clamping
    # here keeps every preset loadable.
    #   hl.animation speed  : max 100.00
    #   hl.curve bezier y   : [-1.00, 2.00]   (x is unbounded)
    MAX_SPEED = 100
    MIN_Y = -1
    MAX_Y = 2
    enabled = "true"
}

{
    line = $0
    sub(/#.*/, "", line)
    line = trim(line)
    if (line == "" || line ~ /^animations[ \t]*\{/ || line == "}") next

    eq = index(line, "=")
    if (eq == 0) next
    key = trim(substr(line, 1, eq - 1))
    val = trim(substr(line, eq + 1))

    if (key == "enabled")   { enabled = isoff(val) ? "false" : "true"; next }
    if (key == "bezier")    { curves[++nc] = val; next }
    if (key == "animation") { anims[++na] = val; next }
}

END {
    print "-- GENERATED FILE -- do not hand-edit."
    if (preset != "")
        print "-- Converted from animations/" preset ".conf by scripts/AnimConfToLua.awk."
    print "-- The animation picker (SUPER SHIFT A) overwrites this file."
    print "---@diagnostic disable: undefined-global"
    print ""
    print "hl.config({ animations = { enabled = " enabled " } })"

    if (nc > 0) {
        print ""
        print "-- Curves"
    }
    for (i = 1; i <= nc; i++) {
        n = split(curves[i], f, ",")
        if (n < 5) {
            print "-- skipped malformed bezier: " curves[i]
            continue
        }
        y1 = clamp(trim(f[3]), MIN_Y, MAX_Y); n1 = clamped
        y2 = clamp(trim(f[5]), MIN_Y, MAX_Y); n2 = clamped
        note = (n1 || n2) ? "  -- y clamped to [" MIN_Y ", " MAX_Y "]; curve differs from the .conf preset" : ""
        printf "hl.curve(%s, { type = \"bezier\", points = { { %s, %s }, { %s, %s } } })%s\n", \
            luastr(trim(f[1])), trim(f[2]), y1, trim(f[4]), y2, note
    }

    if (na > 0) {
        print ""
        print "-- Animations"
    }
    for (i = 1; i <= na; i++) {
        n = split(anims[i], f, ",")
        if (n < 2) {
            print "-- skipped malformed animation: " anims[i]
            continue
        }
        leaf = trim(f[1])
        on = isoff(trim(f[2])) ? "false" : "true"

        # `animation = border, 0` is the shorthand for "off", no speed or curve.
        if (n < 3) {
            printf "hl.animation({ leaf = %s, enabled = false })\n", luastr(leaf)
            continue
        }

        orig = trim(f[3])
        speed = clamp(orig, 0, MAX_SPEED)
        note = clamped ? "  -- speed " orig " clamped to " speed " (hl.animation maximum)" : ""

        curve = (n >= 4) ? trim(f[4]) : ""

        style = ""
        for (j = 5; j <= n; j++)
            style = (style == "") ? trim(f[j]) : style "," trim(f[j])

        out = "hl.animation({ leaf = " luastr(leaf) ", enabled = " on ", speed = " speed
        if (curve != "") out = out ", bezier = " luastr(curve)
        if (style != "") out = out ", style = " luastr(style)
        print out " })" note
    }
}
