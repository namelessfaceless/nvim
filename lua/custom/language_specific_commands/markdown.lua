vim.keymap.set(
  "n",
  "<leader>mi",
  "<M-i>The quick brown fox jumps over the lazy dog. The dog stays blissfully asleep. :)",
  { desc = "Print a standard 80 character string for Markdown formatting." }
)
-- Create an autocommand for markdown filetype using Neovim's Lua API
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown", -- Only for files with filetype 'markdown'
  callback = function()
    -- Enable spell checking locally for the buffer
    vim.opt_local.spell = true
    -- Optionally, set the spell language (e.g., US English)
    vim.opt_local.spelllang = "en_us"
    -- You can add additional buffer-local settings here if needed
  end,
})

print "Markdown Keybinds Loaded"
