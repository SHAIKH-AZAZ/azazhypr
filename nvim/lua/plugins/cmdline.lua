return {
  {
    "VonHeikemen/fine-cmdline.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    config = function()
      local fine = require("fine-cmdline")

      fine.setup({
        cmdline = {
          -- Nerd-font icon for prompt
          prompt = "  ", -- Terminal icon
          smart_completion = true,
        },
        popup = {
          border = {
            style = "rounded",
            text = {
              top = "   Command  ", -- Icon + title
              top_align = "center",
            },
          },
          position = {
            row = "30%", -- slight downward shift
            col = "50%", -- centered horizontally
          },
          size = {
            width = "55%",
            height = "20%",
          },
          win_options = {
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
          },
        },
      })

      -- Remap ":" to open FineCmdline
      vim.keymap.set("n", ":", "<cmd>FineCmdline<CR>", { noremap = true })

      -- Optional: search with icons
      vim.keymap.set("n", "/", "<cmd>FineCmdline /<CR>", {})
      vim.keymap.set("n", "?", "<cmd>FineCmdline ?<CR>", {})
    end,
  },
}
