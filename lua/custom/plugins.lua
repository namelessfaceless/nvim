local cmp = require "cmp"

local plugins = {
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
      return M
    end,
  },
  {
    "rmagatti/auto-session",
    lazy = false,
    keys = {
      -- Will use Telescope if installed or a vim.ui.select picker otherwise
      { "<leader>fs", "<cmd>AutoSession search<CR>", desc = "Session search" },
      {
        "<leader>ws",
        function()
          -- prompt for a session name using the built-in input function:
          local session_name = vim.fn.input "Enter session name: "

          -- optionally check if the user provided something
          if session_name ~= nil and session_name ~= "" then
            -- construct the command with the chosen name
            vim.cmd("AutoSession save " .. session_name)
          else
            print "No session name given. Session not saved."
          end
        end,
        desc = "Save session (prompts for name)",
      },
      { "<leader>wa", "<cmd>AutoSession ToggleAutoSave<CR>", desc = "Toggle autosave" },
    },
    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      root_dir = vim.fn.stdpath "data" .. "/sessions/",
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
