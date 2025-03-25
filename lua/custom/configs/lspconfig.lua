local config = require "plugins.configs.lspconfig"

local on_attach = config.on_attach
local capabilities = config.capabilities

local lspconfig = require "lspconfig"

local servers = {
  "pyright",
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "python" },
    handlers = {
      ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
        config = config or {}
        config.virtual_text = false
        vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
      end,
      ["textDocument/signatureHelp"] = function() end, -- Disable automatic signature help
    },
  }
end

lspconfig.hls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "haskell", "lhaskell", "cabal" },
}

lspconfig.matlab_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "matlab" },
  require "custom.language_specific_commands.matlab",
}

lspconfig.clangd.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "c", "cpp" },
}

lspconfig.marksman.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "markdown" },
  require "custom.language_specific_commands.markdown",
}
