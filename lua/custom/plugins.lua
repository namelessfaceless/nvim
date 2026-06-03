local cmp = require "cmp"

local plugins = {
  -- Copilot inline ghost-text suggestions (not cmp menu).
  -- Keymaps (insert mode only, no conflict with <Tab>/<S-Tab> cmp binds):
  --   <M-l>   Accept suggestion
  --   <M-]>   Next suggestion
  --   <M-[>   Previous suggestion
  --   <C-]>   Dismiss suggestion
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup {
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<M-l>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        panel = { enabled = false },
        -- Disable Copilot ghost-text in noisy/prose filetypes.
        -- Flip any `false` to `true` to re-enable Copilot there.
        filetypes = {
          markdown  = false, -- prose: disable ghost-text
          gitcommit = false, -- keep commit messages focused
          help      = false, -- Vim help buffers
          ["*"]     = true,  -- enable everywhere else
        },
      }
    end,
  },

  -- CopilotChat.nvim — in-editor agentic/chat assistant (closest to Claude Code
  -- available on this Windows branch).  Keymaps live in custom/mappings.lua
  -- under M.copilotchat (<leader>cc prefix).
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      "zbirenbaum/copilot.lua",
      "nvim-lua/plenary.nvim",
    },
    opts = {
      show_help = true,
      window = { layout = "float" },
    },
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        --- lsp
        "omnisharp",           -- C#
        "lua-language-server",
        "clangd",              -- C/C++
        "marksman",            -- Markdown
        "ruff",                -- Python linter/formatter
        "jedi-language-server", -- Python

      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = "User FilePost",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function()
      local M = require "plugins.configs.cmp"
      M.completion.completeopt = "menu,menuone,noselect"
      M.mapping["<CR>"] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Insert,
        select = false,
      }
      -- Sources back to NvChad defaults (copilot-cmp removed)
      return M
    end,
  },
  {
    "rcarriga/nvim-notify",
    lazy = false,
    config = function()
      vim.notify = require "notify"
    end,
  },
}

return plugins
