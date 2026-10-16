-- ~/.config/nvim/lua/plugins/bufferline.lua

return {
  {
    "akinsho/bufferline.nvim",

    opts = {
      options = {
        -- Your custom settings
        mode = "buffers",
        numbers = "none",

        -- Keep LazyVim's default buffer deletion behavior
        close_command = function(n)
          Snacks.bufdelete(n)
        end,

        right_mouse_command = function(n)
          Snacks.bufdelete(n)
        end,

        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,

        indicator = {
          icon = "▎",
          style = "icon",
        },

        buffer_close_icon = "󰅖",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",

        max_name_length = 18,
        max_prefix_length = 15,
        truncate_names = true,
        tab_size = 18,

        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,

        -- Keep LazyVim's diagnostic icons
        diagnostics_indicator = function(_, _, diag)
          local icons = LazyVim.config.icons.diagnostics

          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.Warn .. diag.warning or "")

          return vim.trim(ret)
        end,

        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "center",
            separator = true,
          },
          {
            filetype = "snacks_layout_box",
          },
        },

        -- Keep LazyVim's filetype icon integration
        get_element_icon = function(opts)
          return LazyVim.config.icons.ft[opts.filetype]
        end,

        color_icons = true,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        show_duplicate_prefix = true,
        persist_buffer_sort = true,

        separator_style = "thick",
        enforce_regular_tabs = false,
        always_show_bufferline = true,

        hover = {
          enabled = true,
          delay = 200,
          reveal = { "close" },
        },

        sort_by = "insert_after_current",
      },
    },

    keys = {
      -- LazyVim defaults
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
      { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
      { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
      { "<leader>bj", "<Cmd>BufferLinePick<CR>", desc = "Pick Buffer" },

      -- Navigation
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },

      -- Reordering
      { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
      { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },

      -- Your additional mapping
      { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete Other Buffers" },
    },
  },
}
