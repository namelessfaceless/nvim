-- ~/.config/nvim/lua/custom/language_specific_commands/nabla_setup.lua

local M = {}

-- Setup Nabla for a buffer
function M.setup(bufnr)
  -- Skip if already set up
  if vim.b[bufnr].nabla_keys then
    return
  end

  -- Buffer-local conceal settings (disabled so you always see raw LaTeX)
  vim.opt_local.conceallevel = 0
  vim.opt_local.concealcursor = "" -- always reveal when cursor is on line

  -- Try to load Nabla
  local ok_nabla, nabla = pcall(require, "nabla")
  if not ok_nabla then
    return
  end

  local bufopts = { buffer = bufnr, silent = true }

  -- Toggle keymap - turns Nabla rendering on/off
  vim.keymap.set("n", "<leader>mnt", function()
    if vim.b[bufnr].nabla_enabled then
      nabla.disable_virt()
      vim.b[bufnr].nabla_enabled = false
    else
      nabla.enable_virt()
      vim.b[bufnr].nabla_enabled = true
    end
  end, vim.tbl_extend("force", bufopts, { desc = "Nabla: toggle math rendering" }))

  -- Popup for spot-checking (great for multi-line math)
  vim.keymap.set("n", "<leader>mnp", function()
    nabla.popup()
  end, vim.tbl_extend("force", bufopts, { desc = "Nabla: popup under cursor" }))

  -- Don't auto-enable, let user toggle when needed
  vim.b[bufnr].nabla_enabled = false
  vim.b[bufnr].nabla_keys = true
end

return M
