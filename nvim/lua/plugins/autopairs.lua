-- ============================================================================
-- Auto-pairs - Automatic Bracket/Quote Pairing
-- ============================================================================
-- Automatically closes brackets, quotes, and parentheses as you type
-- Integrates with nvim-cmp for smart completion
-- ============================================================================

return {
  "windwp/nvim-autopairs",
  event = "InsertEnter", -- Load when entering insert mode
  config = function()
    local autopairs = require("nvim-autopairs")
    -- ========================================
    -- Setup Auto-pairs
    -- ========================================
    autopairs.setup({
      check_ts = true, -- Use treesitter for smarter pairing
      ts_config = {
        -- Don't add pairs inside these treesitter nodes
        lua = { "string" }, -- Don't pair inside Lua strings
        javascript = { "template_string" }, -- Don't pair in JS template strings
        typescript = { "template_string" }, -- Don't pair in TS template strings
      },
      -- Disable if you're in a macro
      disable_filetype = { "TelescopePrompt", "vim" },
      -- Disable in certain contexts
      disable_in_macro = true,
      -- Disable in visualblock mode
      disable_in_visualblock = false,
      -- Disable in replace mode
      disable_in_replace_mode = true,
      -- Ignored next char
      ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
      -- Enable basic pairs
      enable_moveright = true,
      enable_afterquote = true,
      enable_check_bracket_line = true,
      enable_bracket_in_quote = true,
      enable_abbr = false,
      break_undo = true,
      -- Map <CR>
      map_cr = true,
      -- Map <BS>
      map_bs = true,
      -- Map <C-w>
      map_c_w = false,
      -- Map <C-h>
      map_c_h = false,
    })

    -- ========================================
    -- Integration with blink.cmp
    -- ========================================
    -- Note: blink.cmp handles autopairs automatically
    -- No additional integration needed

    -- ========================================
    -- Custom Rules
    -- ========================================
    local Rule = require("nvim-autopairs.rule")
    local cond = require("nvim-autopairs.conds")

    -- Add spaces between parentheses
    -- ( | ) -> (  |  )
    autopairs.add_rules({
      Rule(" ", " "):with_pair(function(opts)
        local pair = opts.line:sub(opts.col - 1, opts.col)
        return vim.tbl_contains({ "()", "[]", "{}" }, pair)
      end),
      Rule("( ", " )")
        :with_pair(function()
          return false
        end)
        :with_move(function(opts)
          return opts.prev_char:match(".%)") ~= nil
        end)
        :use_key(")"),
      Rule("{ ", " }")
        :with_pair(function()
          return false
        end)
        :with_move(function(opts)
          return opts.prev_char:match(".%}") ~= nil
        end)
        :use_key("}"),
      Rule("[ ", " ]")
        :with_pair(function()
          return false
        end)
        :with_move(function(opts)
          return opts.prev_char:match(".%]") ~= nil
        end)
        :use_key("]"),
    })

    -- Arrow function for JavaScript/TypeScript
    -- const func = (|) => {}
    autopairs.add_rules({
      Rule("%(.*%)%s*%=>$", " {  }", { "typescript", "typescriptreact", "javascript", "javascriptreact" })
        :use_regex(true)
        :set_end_pair_length(2),
    })
  end,
}
