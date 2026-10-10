local config = require("config")
local h = require("lib")

return {
  h.env("EDITOR", config.defaults.editor),
  h.var("$edit", "${EDITOR:-nano}"),
  h.var("$term", config.defaults.terminal),
  h.var("$files", config.defaults.file_manager),
  h.var("$Search_Engine", h.quote(config.defaults.search_engine)),
}
