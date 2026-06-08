local config = require "plugins.configs.lspconfig"

local on_attach = config.on_attach
local capabilities = config.capabilities

local common = {
  on_attach = on_attach,
  capabilities = capabilities,
}

vim.lsp.config("jedi_language_server", vim.tbl_extend("force", common, {
  filetypes = { "python" },
}))
vim.lsp.enable("jedi_language_server")

vim.lsp.config("hls", vim.tbl_extend("force", common, {
  filetypes = { "haskell", "lhaskell", "cabal" },
}))
vim.lsp.enable("hls")

require "custom.language_specific_commands.matlab"
vim.lsp.config("matlab_ls", vim.tbl_extend("force", common, {
  filetypes = { "matlab" },
}))
vim.lsp.enable("matlab_ls")

vim.lsp.config("clangd", vim.tbl_extend("force", common, {
  filetypes = { "c", "cpp" },
}))
vim.lsp.enable("clangd")

require "custom.language_specific_commands.markdown"
vim.lsp.config("marksman", vim.tbl_extend("force", common, {
  filetypes = { "markdown" },
}))
vim.lsp.enable("marksman")

require "custom.language_specific_commands.tex"
vim.lsp.config("texlab", vim.tbl_extend("force", common, {
  filetypes = { "tex" },
}))
vim.lsp.enable("texlab")

vim.lsp.config("julia_ls", vim.tbl_extend("force", common, {
  filetypes = { "julia" },
}))
vim.lsp.enable("julia_ls")
