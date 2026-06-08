local config = require "plugins.configs.lspconfig"

local on_attach = config.on_attach
local capabilities = config.capabilities

local common = {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Python
vim.lsp.config("jedi_language_server", vim.tbl_extend("force", common, {
  filetypes = { "python" },
}))
vim.lsp.enable("jedi_language_server")

-- C / C++
vim.lsp.config("clangd", vim.tbl_extend("force", common, {
  filetypes = { "c", "cpp" },
}))
vim.lsp.enable("clangd")

-- Markdown
require "custom.language_specific_commands.markdown"
vim.lsp.config("marksman", vim.tbl_extend("force", common, {
  filetypes = { "markdown" },
}))
vim.lsp.enable("marksman")

-- C# (omnisharp installed via Mason)
vim.lsp.config("omnisharp", vim.tbl_extend("force", common, {
  filetypes = { "cs" },
  cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
}))
vim.lsp.enable("omnisharp")
