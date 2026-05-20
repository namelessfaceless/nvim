-- ~/.config/nvim/lua/custom/language_specific_commands/markdown.lua

local GRP = vim.api.nvim_create_augroup("MarkdownWithNabla", { clear = true })
local nabla_setup = require "custom.language_specific_commands.nabla_setup"

-- Buffer-local settings for Markdown
vim.api.nvim_create_autocmd("FileType", {
  group = GRP,
  pattern = { "markdown" },
  callback = function(args)
    -- Buffer-local basics
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.formatoptions:append "t"
    vim.opt_local.textwidth = 60

    -- Setup Nabla (conceal settings + keymaps)
    nabla_setup.setup(args.buf)
  end,
})

-- Re-enable Nabla virtual text after writes (if cleared)
vim.api.nvim_create_autocmd("BufWritePost", {
  group = GRP,
  pattern = { "*.md", "*.mdx", "*.markdown" },
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if ft ~= "markdown" or not vim.b[args.buf].nabla_enabled then
      return
    end
    local ok_nabla, nabla = pcall(require, "nabla")
    if ok_nabla then
      nabla.enable_virt()
    end
  end,
})
