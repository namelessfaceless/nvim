local config = require "plugins.configs.lspconfig"

local on_attach = function(client, bufnr)
  config.on_attach(client, bufnr)

  -- Keybinding to show hover documentation
  vim.api.nvim_buf_set_keymap(
    bufnr,
    "n",
    "<leader>h",
    "<cmd>lua vim.lsp.buf.hover()<CR>",
    { noremap = true, silent = true }
  )

  -- Keybinding to show diagnostics
  vim.api.nvim_buf_set_keymap(
    bufnr,
    "n",
    "<leader>e",
    '<cmd>lua vim.diagnostic.open_float(nil, { focusable = false, close_events = {"BufLeave", "CursorMoved", "InsertEnter", "FocusLost"}, border = "rounded", source = "always", prefix = " ", scope = "cursor" })<CR>',
    { noremap = true, silent = true }
  )

  -- Keybinding to show signature help
  vim.api.nvim_buf_set_keymap(
    bufnr,
    "n",
    "<leader>s",
    "<cmd>lua vim.lsp.buf.signature_help()<CR>",
    { noremap = true, silent = true }
  )
end

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
