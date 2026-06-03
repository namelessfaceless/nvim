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

M.copilotchat = {
  n = {
    ["<leader>co"] = { "<cmd>CopilotChatOpen<CR>", "CopilotChat open" },
    ["<leader>ct"] = { "<cmd>CopilotChatToggle<CR>", "CopilotChat toggle" },
    ["<leader>cf"] = { "<cmd>CopilotChatFix<CR>", "CopilotChat fix buffer" },
    ["<leader>cr"] = { "<cmd>CopilotChatRefactor<CR>", "CopilotChat refactor buffer" },
    ["<leader>cg"] = { "<cmd>CopilotChatTests<CR>", "CopilotChat generate tests" },
    ["<leader>cx"] = { "<cmd>CopilotChatExplain<CR>", "CopilotChat explain buffer" },
    ["<leader>cp"] = {
      function()
        vim.ui.input({ prompt = "CopilotChat: " }, function(input)
          if input and input ~= "" then
            vim.api.nvim_cmd({ cmd = "CopilotChat", args = { input } }, {})
          end
        end)
      end,
      "CopilotChat quick prompt",
    },
  },
  v = {
    ["<leader>cf"] = { "<cmd>CopilotChatFix<CR>", "CopilotChat fix selection" },
    ["<leader>cr"] = { "<cmd>CopilotChatRefactor<CR>", "CopilotChat refactor selection" },
    ["<leader>cg"] = { "<cmd>CopilotChatTests<CR>", "CopilotChat generate tests" },
    ["<leader>cx"] = { "<cmd>CopilotChatExplain<CR>", "CopilotChat explain selection" },
  },
}

return M
