-- wallust template - colors-nvim.lua
-- Generated into ~/.config/nvim/colors/wallust.lua, so `:colorscheme wallust` loads it.
require("base16-colorscheme").setup({
  base00 = "{{background}}",                 -- editor bg
  base01 = "{{background | lighten(0.06)}}", -- statusline / float bg
  base02 = "{{background | lighten(0.14)}}", -- selection
  base03 = "{{color8}}",                     -- comments
  base04 = "{{color7}}",                     -- dark fg
  base05 = "{{foreground}}",                 -- fg
  base06 = "{{color15}}",
  base07 = "{{color15}}",
  base08 = "{{color1}}",  -- variables, errors
  base09 = "{{color9}}",  -- numbers, constants
  base0A = "{{color3}}",  -- types
  base0B = "{{color2}}",  -- strings
  base0C = "{{color6}}",  -- regex, escapes
  base0D = "{{color4}}",  -- functions
  base0E = "{{color5}}",  -- keywords
  base0F = "{{color13}}", -- deprecated
})
vim.g.colors_name = "wallust"
