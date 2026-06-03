local M = {}

-- Function to show diagnostics on hover
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    local opts = {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = "rounded",
      source = "always", -- show source in diagnostics popup window
      prefix = " ",
      scope = "cursor",
    }
    vim.diagnostic.open_float(nil, opts)
  end,
})

M.copilot = {
  n = {
    ["<leader>ce"] = { "<cmd>Copilot enable<CR>", "Copilot enable" },
    ["<leader>cd"] = { "<cmd>Copilot disable<CR>", "Copilot disable" },
    ["<leader>cs"] = { "<cmd>Copilot status<CR>", "Copilot status" },
  },
}

return M
