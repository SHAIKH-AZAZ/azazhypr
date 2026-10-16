local h = require("lib")

return {
  h.comment("Add custom window rules here. Defaults are sourced from the vendor config."),
  h.rule("windowrule", "match:class ^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr|[Ff]irefox-bin)$, tag +browser"),
  h.rule("windowrule", "match:class ^(VSCode|code|code-url-handler)$, tag +projects"),
  h.rule("windowrule", "match:class ^(Alacritty|kitty|kitty-dropterm)$, tag +terminal"),
  h.rule("windowrule", "match:tag terminal, opacity 0.9 0.7"),
  h.rule("windowrule", "match:fullscreen true, idle_inhibit fullscreen"),
  h.rule("layerrule", "match:namespace rofi, blur on"),
  h.rule("layerrule", "match:namespace notifications, blur on"),
}
