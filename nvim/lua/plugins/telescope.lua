return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<C-,>",
        function()
          require("telescope.builtin").find_files({
            cwd = vim.uv.cwd(),
            hidden = true,
          })
        end,
        desc = "Find Files (CWD)",
      },
    },
  },
}
