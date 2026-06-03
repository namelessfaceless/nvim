local config = require "plugins.configs.lspconfig"

local on_attach = config.on_attach
local on_init = config.on_init
local capabilities = config.capabilities

local common = {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
}

local function setup_server(name, opts)
  if vim.lsp.config and vim.lsp.enable then
    vim.lsp.config(name, opts)
    vim.lsp.enable(name)
    return
  end

  require("lspconfig")[name].setup(opts)
end

-- Python
setup_server("jedi_language_server", vim.tbl_extend("force", common, {
  filetypes = { "python" },
}))

-- C / C++
setup_server("clangd", vim.tbl_extend("force", common, {
  filetypes = { "c", "cpp" },
}))

-- Markdown
require "custom.language_specific_commands.markdown"
setup_server("marksman", vim.tbl_extend("force", common, {
  filetypes = { "markdown" },
}))

-- C# (omnisharp installed via Mason)
setup_server("omnisharp", vim.tbl_extend("force", common, {
  filetypes = { "cs" },
  cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
}))
