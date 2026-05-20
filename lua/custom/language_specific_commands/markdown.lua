-- ~/.config/nvim/lua/custom/language_specific_commands/markdown.lua

local GRP = vim.api.nvim_create_augroup("MarkdownSettings", { clear = true })

-- Buffer-local settings for Markdown
vim.api.nvim_create_autocmd("FileType", {
  group = GRP,
  pattern = { "markdown" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.formatoptions:append "t"
    vim.opt_local.textwidth = 60
  end,
})
