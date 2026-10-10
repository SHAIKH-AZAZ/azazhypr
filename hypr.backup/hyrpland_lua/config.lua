local home = os.getenv("HOME")

local M = {
  home = home,
  paths = {
    hypr = home .. "/.config/hypr",
    configs = home .. "/.config/hypr/configs",
    user_configs = home .. "/.config/hypr/UserConfigs",
    scripts = home .. "/.config/hypr/scripts",
    user_scripts = home .. "/.config/hypr/UserScripts",
    generated = home .. "/.config/hypr/hyrpland_lua/generated",
  },
}

M.defaults = {
  editor = "nvim",
  terminal = "kitty",
  file_manager = "thunar",
  search_engine = "https://www.google.com/search?q={}",
  main_mod = "SUPER",
}

return M
