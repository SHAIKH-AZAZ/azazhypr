-- Static ink-black scheme, matches kitty ink-black.conf. Not touched by wallust.
require("base16-colorscheme").setup({
  base00 = "#000000", -- editor bg
  base01 = "#111111", -- statusline / float bg
  base02 = "#2A2A2A", -- selection
  base03 = "#686868", -- comments
  base04 = "#B0B0B0", -- dark fg
  base05 = "#F1F1F0", -- fg
  base06 = "#F1F1F0",
  base07 = "#FFFFFF",
  base08 = "#FF5C57", -- variables, errors
  base09 = "#FF9F43", -- numbers, constants
  base0A = "#F3F99D", -- types
  base0B = "#5AF78E", -- strings
  base0C = "#9AEDFE", -- regex, escapes
  base0D = "#57C7FF", -- functions
  base0E = "#FF6AC1", -- keywords
  base0F = "#B2643C", -- deprecated
})
for _, g in ipairs({ "Cursor", "lCursor", "TermCursor" }) do
  vim.api.nvim_set_hl(0, g, { fg = "#000000", bg = "#FFFFFF" })
end
vim.g.colors_name = "inkblack"
