-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */ --
-- Environment variables — Hyprland Lua version
-- See https://wiki.hyprland.org/Configuring/Environment-variables/
--
-- NOTE: in the .conf syntax, `env = KEY,v1,v2,v3` joins values with `:`
--       (e.g. `env = GDK_BACKEND,wayland,x11,*` ⇒ GDK_BACKEND=wayland:x11:*).
--       Semicolons are kept verbatim. The Lua API takes the final string
--       directly, so I pre-join commas → colons below.
---@diagnostic disable: undefined-global

-- Current Version of JakooLit Dotfiles
hl.env("DOTS_VERSION", "2.3.20")

-- /* ---- 🧰 Toolkit Backend Variables 🧰 */
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

-- Run SDL2 applications on Wayland.
-- Remove or set to x11 if games that provide older versions of SDL cause compatibility issues
-- hl.env("SDL_VIDEODRIVER", "wayland")

-- /* ---- 📁 XDG Specifications 📁 */
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- /* ---- 🪟 QT Variables 🪟 */
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct") -- second assignment wins, kept for parity

-- /* ---- 🎨 hyprland-qt-support 🎨 */
hl.env("QT_QUICK_CONTROLS_STYLE", "org.hyprland.style")

-- /* ---- 🖥️ xwayland apps scale fix (matches Monitors.conf scaling) 🖥️ */
-- 1 is 100%, 1.5 is 150% — see https://wiki.hyprland.org/Configuring/XWayland/
hl.env("GDK_SCALE", "1")
hl.env("QT_SCALE_FACTOR", "1")

-- /* ---- 🖱️ Bibata-Modern-Ice-Cursor 🖱️ */
-- NOTE: requires the hyprcursor version of the theme.
-- https://wiki.hyprland.org/Hypr-Ecosystem/hyprcursor/
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")

-- /* ---- 🦊 firefox 🦊 */
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- /* ---- ⚛️ Electron >28 apps (may help) ⚛️ */
-- https://www.electronjs.org/docs/latest/api/environment-variables
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto") -- auto-selects Wayland if possible, X11 otherwise

-- /* ---- 🟢 NVIDIA — from Hyprland Wiki 🟢 ---- */
-- See https://wiki.hyprland.org/Nvidia/#environment-variables
-- (auto-detected at install; uncomment when on Nvidia)

-- hl.env("LIBVA_DRIVER_NAME",            "nvidia")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME",    "nvidia")
-- hl.env("NVD_BACKEND",                  "direct")
-- hl.env("GSK_RENDERER",                 "ngl")

-- /* ---- ⚠️ Additional NVIDIA ENVs — activate with care ⚠️ */
-- hl.env("GBM_BACKEND",                  "nvidia-drm")
-- hl.env("__GL_GSYNC_ALLOWED",           "1")            -- adaptive VSync
-- hl.env("__NV_PRIME_RENDER_OFFLOAD",    "1")
-- hl.env("__VK_LAYER_NV_optimus",        "NVIDIA_only")
-- hl.env("WLR_DRM_NO_ATOMIC",            "1")

-- /* ---- 🖥️ For VM (and possibly NVIDIA) 🖥️ */
-- LIBGL_ALWAYS_SOFTWARE forces mesa software rendering
-- hl.env("LIBGL_ALWAYS_SOFTWARE",         "1")            -- ⚠ may crash Hyprland
-- hl.env("WLR_RENDERER_ALLOW_SOFTWARE",   "1")

-- /* ---- 🦊 nvidia firefox 🦊 */
-- https://github.com/elFarto/nvidia-vaapi-driver#configuration
-- hl.env("MOZ_DISABLE_RDD_SANDBOX", "1")
-- hl.env("EGL_PLATFORM",           "wayland")

-- /* ---- 💎 Aquamarine Environment Variables (Hyprland > 0.45) 💎 */
-- https://wiki.hyprland.org/Configuring/Environment-variables/#aquamarine-environment-variables
-- hl.env("AQ_TRACE",          "1")                       -- verbose logging
-- hl.env("AQ_DRM_DEVICES",    "/dev/dri/card1:/dev/dri/card0")  -- explicit GPU list
-- hl.env("AQ_MGPU_NO_EXPLICIT","1")                      -- disable explicit sync on mgpu buffers
-- hl.env("AQ_NO_MODIFIERS",   "1")                       -- disable modifiers for DRM buffers

-- /* ---- 🪟 Hyprland Environment Variables 🪟 */
-- https://wiki.hyprland.org/Configuring/Environment-variables/#hyprland-environment-variables
-- hl.env("HYPRLAND_TRACE",      "1")   -- verbose logging
-- hl.env("HYPRLAND_NO_RT",      "1")   -- disable realtime priority
-- hl.env("HYPRLAND_NO_SD_NOTIFY","1")  -- disable sd_notify calls
-- hl.env("HYPRLAND_NO_SD_VARS", "1")   -- disable systemd/dbus env management

