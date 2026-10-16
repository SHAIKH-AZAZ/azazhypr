-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Pick up new wallust palette after a wallpaper change
vim.api.nvim_create_autocmd("FocusGained", {
  callback = function()
    if vim.g.colors_name == "wallust" then
      vim.cmd.colorscheme("wallust")
    end
  end,
})
