# Hyprland Lua Profile Draft

This folder is a separate Lua-based draft for generating Hyprland config files.
It does not affect the active profile unless you explicitly source the generated
files from another Hyprland profile.

Generate config files:

```sh
cd ~/.config/hypr/hyrpland_lua
lua emit.lua
```

Generated files are written to:

```text
~/.config/hypr/hyrpland_lua/generated/
```

Use from another profile by sourcing:

```ini
source = ~/.config/hypr/hyrpland_lua/generated/hyprland.conf
```

Notes:

- Hyprland still reads Hyprlang `.conf` syntax. Lua is used here as a generator.
- The active JaKooLit config is left untouched.
- Vendor defaults are referenced with `source = ...` where practical, while user
  settings are represented in Lua tables for easier future editing.
