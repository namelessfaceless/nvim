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

-- CopilotChat keymaps — <leader>cc prefix (no collision with ce/cd/cs above).
-- Normal-mode actions work on the whole buffer; visual-mode actions work on the
-- selected lines.  All bindings open a floating chat window.
M.copilotchat = {
  n = {
    ["<leader>cct"] = { "<cmd>CopilotChatToggle<CR>",  "CopilotChat toggle" },
    ["<leader>cce"] = { "<cmd>CopilotChatExplain<CR>", "CopilotChat explain code" },
    ["<leader>ccf"] = { "<cmd>CopilotChatFix<CR>",     "CopilotChat fix code" },
    ["<leader>ccr"] = { "<cmd>CopilotChatRefactor<CR>","CopilotChat refactor code" },
    ["<leader>cck"] = { "<cmd>CopilotChatTests<CR>",   "CopilotChat generate tests" },
    ["<leader>cci"] = { "<cmd>CopilotChatInline<CR>",  "CopilotChat inline prompt" },
  },
  v = {
    ["<leader>cct"] = { "<cmd>CopilotChatToggle<CR>",  "CopilotChat toggle" },
    ["<leader>cce"] = { "<cmd>CopilotChatExplain<CR>", "CopilotChat explain selection" },
    ["<leader>ccf"] = { "<cmd>CopilotChatFix<CR>",     "CopilotChat fix selection" },
    ["<leader>ccr"] = { "<cmd>CopilotChatRefactor<CR>","CopilotChat refactor selection" },
    ["<leader>cck"] = { "<cmd>CopilotChatTests<CR>",   "CopilotChat generate tests for selection" },
    ["<leader>cci"] = { "<cmd>CopilotChatInline<CR>",  "CopilotChat inline prompt" },
  },
}

return M
