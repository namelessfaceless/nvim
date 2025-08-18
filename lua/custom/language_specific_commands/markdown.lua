vim.keymap.set(
  "n",
  "<leader>mi",
  "<M-i><!The quick brown fox jumps over the lazy dog. The dog takes a nice nap. :)>",
  { desc = "Print a standard 80 character string for Markdown formatting." }
)
-- Create an autocommand for markdown filetype using Neovim's Lua API
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "tex" },
  -- Only for files with filetype 'markdown'
  callback = function()
    -- Enable spell checking locally for the buffer
    vim.opt_local.spell = true
    -- Optionally, set the spell language (e.g., US English)
    vim.opt_local.spelllang = "en_us"
    -- You can add additional buffer-local settings here if needed
    -- Set the conceal level to 2 to render links in a pretty way
    vim.wo.conceallevel = 2
    -- and set it to conceal in normal and command modes
    vim.wo.concealcursor = "nc"
    -- wrap text at 80 chars and show a visual line guide
    vim.opt_local.textwidth = 60
    vim.opt_local.formatoptions:append "t"
  end,
})

print "Markdown Keybinds Loaded"
