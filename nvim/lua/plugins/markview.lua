return {
  {
    "OXY2DEV/markview.nvim",

    -- Markview is already lazy internally.
    lazy = false,

    config = function()
      require("markview").setup({
        preview = {
          icon_provider = "mini",
        },

        markdown = {
          -- Keep Markdown rendering clean.
          headings = {
            enable = true,
          },

          list_items = {
            enable = true,
          },

          block_quotes = {
            enable = true,
          },

          code_blocks = {
            enable = true,
            style = "block",
          },

          horizontal_rules = {
            enable = true,
          },

          inline_codes = {
            enable = true,
          },

          tables = {
            enable = true,
          },

          links = {
            enable = true,
          },

          checkboxes = {
            enable = true,
          },
        },
      })

      -- Markdown only
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.opt_local.wrap = false
          vim.opt_local.conceallevel = 2
        end,
      })
    end,

    keys = {
      {
        "<leader>mp",
        "<cmd>Markview toggle<cr>",
        ft = "markdown",
        desc = "Markdown Preview Toggle",
      },

      {
        "<leader>ms",
        "<cmd>Markview splitToggle<cr>",
        ft = "markdown",
        desc = "Markdown Split Preview",
      },

      {
        "<leader>mh",
        "<cmd>Markview hybridToggle<cr>",
        ft = "markdown",
        desc = "Markdown Hybrid Preview",
      },
    },
  },
}
