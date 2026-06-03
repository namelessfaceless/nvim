local plugins = {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup {
        -- Alt-l accepts the current ghost text and Alt-h dismisses it, which
        -- keeps cmp's existing Tab / Shift-Tab flow unchanged.
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<M-l>",
            dismiss = "<M-h>",
          },
        },
        panel = { enabled = false },
        -- Markdown / help prose is usually noisy with inline AI suggestions;
        -- flip any of these back to true if you want Copilot there again.
        filetypes = {
          markdown = false,
          gitcommit = false,
          help = false,
          ["*"] = true,
        },
      }
    end,
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
      local cmp = require "cmp"
      local M = require "plugins.configs.cmp"
      M.completion.completeopt = "menu,menuone,noselect"
      M.mapping["<CR>"] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Insert,
        select = false,
      }
      return M
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    cmd = {
      "CopilotChat",
      "CopilotChatOpen",
      "CopilotChatClose",
      "CopilotChatToggle",
      "CopilotChatStop",
      "CopilotChatReset",
      "CopilotChatSave",
      "CopilotChatLoad",
      "CopilotChatPrompts",
      "CopilotChatModels",
      "CopilotChatExplain",
      "CopilotChatReview",
      "CopilotChatRefactor",
      "CopilotChatFix",
      "CopilotChatOptimize",
      "CopilotChatDocs",
      "CopilotChatTests",
      "CopilotChatCommit",
    },
    dependencies = { "nvim-lua/plenary.nvim", "zbirenbaum/copilot.lua" },
    config = function(_, opts)
      require("CopilotChat").setup(opts)
    end,
    opts = {
      prompts = {
        Refactor = {
          prompt = "Refactor the selected code to improve clarity and maintainability without changing behavior.",
        },
      },
    },
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
