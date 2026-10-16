-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
-- Environment variables.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
--
-- Set your default editor through hl.env in UserConfigs/01-UserDefaults.lua
---@diagnostic disable: undefined-global

--- QT Variables ---
-- hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
-- hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
-- hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
-- hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

--- xwayland apps scale fix (useful if you use monitor scaling) ---
-- Set the same value you use for scaling in monitors.lua.
-- 1 is 100%, 1.5 is 150%
-- see https://wiki.hypr.land/Configuring/XWayland/
-- hl.env("GDK_SCALE", "1")
-- hl.env("QT_SCALE_FACTOR", "1")

--- NVIDIA ---
-- From the Hyprland wiki. These are applied automatically when an nvidia GPU
-- is detected. See https://wiki.hypr.land/Nvidia/#environment-variables
-- hl.env("LIBVA_DRIVER_NAME", "nvidia")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- hl.env("NVD_BACKEND", "direct")
-- hl.env("GSK_RENDERER", "ngl")

--- additional ENVs for nvidia. Caution, activate with care ---
-- hl.env("GBM_BACKEND", "nvidia-drm")
-- hl.env("__GL_GSYNC_ALLOWED", "1")           -- adaptive Vsync
-- hl.env("__NV_PRIME_RENDER_OFFLOAD", "1")
-- hl.env("__VK_LAYER_NV_optimus", "NVIDIA_only")
-- hl.env("WLR_DRM_NO_ATOMIC", "1")

--- FOR VM and POSSIBLY NVIDIA ---
-- LIBGL_ALWAYS_SOFTWARE = software mesa rendering
-- hl.env("LIBGL_ALWAYS_SOFTWARE", "1")        -- Warning. May cause hyprland to crash
-- hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")

--- nvidia firefox ---
-- check this post https://github.com/elFarto/nvidia-vaapi-driver#configuration
-- hl.env("MOZ_DISABLE_RDD_SANDBOX", "1")
-- hl.env("EGL_PLATFORM", "wayland")

--- Aquamarine Environment Variables (Hyprland > 0.45) ---
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/#aquamarine-environment-variables
-- hl.env("AQ_TRACE", "1")                     -- Enables more verbose logging
-- hl.env("AQ_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card0") -- explicit GPU list, first is primary
-- hl.env("AQ_MGPU_NO_EXPLICIT", "1")          -- Disables explicit syncing on mgpu buffers
-- hl.env("AQ_NO_MODIFIERS", "1")              -- Disables modifiers for DRM buffers
