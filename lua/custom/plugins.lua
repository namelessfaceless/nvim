local cmp = require "cmp"

local plugins = {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        --- lsp
        "rust-analyzer",
        "haskell-language-server",
        "matlab-language-server",
        "lua-language-server",
        "clangd",
        "marksman",
        "ruff",
        "jedi-language-server",

        --- formatters
        "stylua",
        "clang-format",
        "fourmolu",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^4",
    ft = { "rust" },
  },
  {
    "mfussenegger/nvim-dap",
    init = function()
      require("core.utils").load_mappings "dap"
    end,
  },
  {
    "saecki/crates.nvim",
    ft = { "rust", "toml" },
    config = function(_, opts)
      local crates = require "crates"
      crates.setup(opts)
      require("cmp").setup.buffer {
        sources = { { name = "crates" } },
      }
      crates.show()
      require("core.utils").load_mappings "crates"
    end,
  },
  {
    "rust-lang/rust.vim",
    ft = "rust",
    init = function()
      vim.g.rustfmt_autosave = 1
    end,
    config = function()
      require "custom.language_specific_commands.rust"
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    lazy = false,
    config = function(_, opts)
      require("nvim-dap-virtual-text").setup()
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
      table.insert(M.sources, { name = "crates" })
      return M
    end,
  },
  {
    "susliko/tla.nvim",
    ft = { "tla" },
    config = function()
      require("tla").setup {
        java_executable = "/usr/bin/java",
        java_opts = { "-XX:+UseParallelGC" },
      }
    end,
  },
  {
    "florentc/vim-tla",
    ft = { "tla" },
    -- Optional: specify events or commands for lazy loading
    event = "BufRead",
    cmd = { "TLAPlusCommand" },
  },
  {
    "rmagatti/auto-session",
    lazy = false,
    keys = {
      -- Will use Telescope if installed or a vim.ui.select picker otherwise
      { "<leader>fs", "<cmd>SessionSearch<CR>", desc = "Session search" },
      {
        "<leader>ws",
        function()
          -- prompt for a session name using the built-in input function:
          local session_name = vim.fn.input "Enter session name: "

          -- optionally check if the user provided something
          if session_name ~= nil and session_name ~= "" then
            -- construct the command with the chosen name
            vim.cmd("SessionSave " .. session_name)
          else
            print "No session name given. Session not saved."
          end
        end,
        desc = "Save session (prompts for name)",
      },
      { "<leader>wa", "<cmd>SessionToggleAutoSave<CR>", desc = "Toggle autosave" },
    },
    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      root_dir = os.getenv "HOME" .. "/Documents/Dane's Vault/.sessions/",
    },
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        -- Customize or remove this keymap to your liking
        "<leader>F",
        function()
          require("conform").format { async = true }
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    -- This will provide type hinting with LuaLS
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
      -- Define your formatters
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black" },
        rust = { "rustfmt" },
        haskell = { "fourmolu" },
        c = { "clang-format" },
      },
      -- Set default options
      default_format_opts = {
        lsp_format = "fallback",
      },
      -- Set up format-on-save
      format_on_save = { timeout_ms = 500 },
      -- Customize formatters
      formatters = {
        shfmt = {
          prepend_args = { "-i", "2" },
        },
      },
    },
    init = function()
      -- If you want the formatexpr, here is the place to set it
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
}

return plugins
