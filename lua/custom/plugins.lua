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
        "clangd",
        "marksman",

        --- formatters
        "stylua",
        "black",
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
      { "<leader>ws", "<cmd>SessionSave<CR>", desc = "Save session" },
      { "<leader>wa", "<cmd>SessionToggleAutoSave<CR>", desc = "Toggle autosave" },
    },
    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
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
  {
    "goolord/alpha-nvim",
    lazy = false,
    requires = { "kyazdani42/nvim-web-devicons" },
    config = function()
      local alpha = require "alpha"
      local dashboard = require "alpha.themes.dashboard"

      math.randomseed(os.time())

      local function pick_color()
        local colors = { "String", "Identifier", "Keyword", "Number" }
        return colors[math.random(#colors)]
      end

      local function footer()
        local datetime = os.date " %d-%m-%Y   %H:%M:%S"
        local version = vim.version()
        local nvim_version_info = "   v" .. version.major .. "." .. version.minor .. "." .. version.patch

        return datetime .. nvim_version_info
      end

      local logo = {
        [[     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                ]],
        [[   %%%%===========================================%%%%                                              ]],
        [[  %%%%%=-------------------------------------------=#%%%                                            ]],
        [[  %%%%%=---------------------------------------------=#%%%                                          ]],
        [[  %%%%%=-----------------------------------------------=#%%                                         ]],
        [[  %%%%%====----------==========================---------+%%                                         ]],
        [[  %%%%%%%%#----------*%%%%%%%%%%%%%%%%%%%%%%%%%---------+%%                                         ]],
        [[  %%%%%%%%#----------*%%%%%%%%%%%%%%%%%%%%%%%%%---------+%%                                         ]],
        [[      %%%%#----------*%%%%%%%%%%%%%%%%%%%%%%%%%---------+%%                                         ]],
        [[      %%%%#----------*%%                  %%%%%---------+%%                                         ]],
        [[      %%%%#----------*%%                  %%%%%---------+%%                                         ]],
        [[      %%%%#----------*%####################%%%%---------+%%                                         ]],
        [[      %%%%#----------+*************************---------+%%                                         ]],
        [[      %%%%#---------------------------------------------+%%                                         ]],
        [[      %%%%#--------------------------------------------+%%%                                         ]],
        [[      %%%%#------------------------------------------=#%%%%                                         ]],
        [[      %%%%#-----------------------------------------#%%%%                                            ]],
        [[      %%%%#----------=============================+%%%%                                              ]],
        [[      %%%%#----------*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                ]],
        [[      %%%%#----------*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                 ]],
        [[      %%%%#----------*%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                    ]],
        [[      %%%%#----------*%%                                                                            ]],
        [[      %%%%#----------*%%       %%%##**++++++*#%%%%%%% %%#***#%%                                      ]],
        [[%#+=% %%%%#----------*%%   %%%#=--------==---------------------=%===+#%%##%                         ]],
        [[%==%  %%%%#----------*%%%%=+#=-----------+------------=+-------+==--=*=#=-==%%                      ]],
        [[#-=%  %%%%#---------=#*===**------------*=-----------++-------=%=----*=--=+=*%*#                    ]],
        [[%*-#% %%%%#----==*#+--=+#%#----------=*+------------*=-------=+=----+#------+%=#                    ]],
        [[ %*==#%%%%#*##*==-=**#%%%+=--------+*=+**----------*++=----+*#=---=*#%*+==-*  %                     ]],
        [[   %#+==--==+*#*+===*#*=--------=*+*%%%%%#+=-==----%#=---+#=---=#%%%%%%  %*+%                       ]],
        [[      %%%%#=-----**=----=+*#####% %%%%%%%   %#*+=#=#==--++-=+#%%%%%%%*==%%                          ]],
        [[      %%%%#-----+*==*#%%          %#++==#%     %%%%%%#=--=%      %%#*=+#=-=+%%                      ]],
        [[      %%%%#----+*-=%#%%%             %+=-*%  %%       %#=-=#          %%#==--=*#%%%%                ]],
        [[   %%%%%%%#----*=---=*#%%%%            %+-===%#%        %*=-==*#%         %####==-+**               ]],
        [[  %%%%%=----------------#%%     %%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%]],
        [[  %%%%%=----------------#%%     %%-----------+%% %%=-------------------=%% %%--------------------=%%]],
        [[  %%%%%=----------------#%%     %%%%%%=---*%%%%% %%=----#%%*----%%%%=--=%% %%-----#%%+---=%%%%=--=%%]],
        [[  %%%%%=----------------#%%         %%=---*%     %%%%%%%%%%*----%%%%%%%%%% %%%%%%%%%%+---=%%%%%%%%%%]],
        [[  %%%%%=----------------#%%         %%=---*%              %*----%%                  %+---=%%        ]],
        [[  %%%%%##################%%     %%%%%%=---*%%%%%      %%%%%*----%%%%%           %%%%%+---=%%%%%%    ]],
        [[  %%%%%%%%%%%%%%%%%%%%%%%%%     %%-----------+%%      %%=----------*%%          %%=----------*%%    ]],
        [[  %%%%%%%%%%%%%%%%%%%%%%%%%     %%############%%      %%###########%%%          %%############%%    ]],
      }

      dashboard.section.header.val = logo
      dashboard.section.header.opts.hl = pick_color()

      dashboard.section.buttons.val = {
        dashboard.button("<Leader>ff", "  File Explorer"),
        dashboard.button("<Leader>fo", "  Find File"),
        dashboard.button("<Leader>fw", "  Find Word"),
        dashboard.button("<Leader>fs", "󱝆  Find Session"),
        dashboard.button("<Leader>ps", "  Update plugins"),
        dashboard.button("q", "󰩈  Quit", ":qa<cr>"),
      }

      dashboard.section.footer.val = footer()
      dashboard.section.footer.opts.hl = "Constant"

      alpha.setup(dashboard.opts)

      vim.cmd [[ autocmd FileType alpha setlocal nofoldenable ]]
    end,
  },
}
return plugins
