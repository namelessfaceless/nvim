-- ~/.config/nvim/lua/custom/language_specific_commands/tex.lua

local GRP = vim.api.nvim_create_augroup("TeXWithNabla", { clear = true })
local nabla_setup = require "custom.language_specific_commands.nabla_setup"

-- Textcolor highlight operator: wraps motions/selections in \textcolor{color}{...}
local function make_textcolor_op(color)
  return function(type)
    local s = vim.api.nvim_buf_get_mark(0, "[")
    local e = vim.api.nvim_buf_get_mark(0, "]")
    local lines = vim.api.nvim_buf_get_lines(0, s[1] - 1, e[1], false)
    if #lines == 0 then return end

    if type == "char" then
      lines[#lines] = lines[#lines]:sub(1, e[2] + 1)
      lines[1] = lines[1]:sub(s[2] + 1)
      local text = table.concat(lines, "\n")
      local wrapped = string.format("\\textcolor{%s}{%s}", color, text)
      vim.api.nvim_buf_set_text(0, s[1] - 1, s[2], e[1] - 1, e[2] + 1, vim.split(wrapped, "\n"))
    elseif type == "line" then
      local text = table.concat(lines, "\n")
      local wrapped = string.format("\\textcolor{%s}{%s}", color, text)
      vim.api.nvim_buf_set_lines(0, s[1] - 1, e[1], false, vim.split(wrapped, "\n"))
    end
  end
end

local textcolor_colors = {
  b = "blue",
  r = "red",
  g = "green",
}

-- Register global functions so operatorfunc can reference them via v:lua
for key, color in pairs(textcolor_colors) do
  _G["_textcolor_" .. color] = make_textcolor_op(color)
end

-- Check if cursor is currently inside a \textcolor{...}{...} block
local function cursor_in_textcolor()
  local save = vim.fn.winsaveview()
  if vim.fn.search("\\\\textcolor{", "bcW") == 0 then
    vim.fn.winrestview(save)
    return false
  end
  -- Navigate through both brace pairs to find the end of the block
  vim.fn.search("{", "cW")
  vim.cmd("normal! %")
  vim.fn.search("{", "W")
  vim.cmd("normal! %")
  local end_pos = vim.api.nvim_win_get_cursor(0)
  vim.fn.winrestview(save)
  -- Original cursor must be at or before the closing }
  if save.lnum < end_pos[1] or (save.lnum == end_pos[1] and save.col <= end_pos[2]) then
    return true
  end
  return false
end

-- Change color of surrounding \textcolor{old}{...} to a new color
local function change_textcolor(new_color)
  local save = vim.fn.winsaveview()
  vim.fn.search("\\\\textcolor{", "bcW")
  vim.fn.search("{", "cW")
  local bpos = vim.api.nvim_win_get_cursor(0)
  local color_row, color_col = bpos[1] - 1, bpos[2] + 1
  vim.cmd("normal! %")
  local epos = vim.api.nvim_win_get_cursor(0)
  local end_row, end_col = epos[1] - 1, epos[2]
  vim.api.nvim_buf_set_text(0, color_row, color_col, end_row, end_col, { new_color })
  vim.fn.winrestview(save)
end

-- Remove \textcolor{...}{content} wrapper, keeping content
local function remove_textcolor()
  if not cursor_in_textcolor() then
    vim.notify("No \\textcolor found", vim.log.levels.WARN)
    return
  end
  local save = vim.fn.winsaveview()
  vim.fn.search("\\\\textcolor{", "bcW")
  local pos = vim.api.nvim_win_get_cursor(0)
  local start_row, start_col = pos[1] - 1, pos[2]
  vim.fn.search("{", "cW")
  vim.cmd("normal! %")
  vim.fn.search("{", "W")
  local cpos = vim.api.nvim_win_get_cursor(0)
  local content_row, content_col = cpos[1] - 1, cpos[2]
  vim.cmd("normal! %")
  local epos = vim.api.nvim_win_get_cursor(0)
  local end_row, end_col = epos[1] - 1, epos[2]
  local content = vim.api.nvim_buf_get_text(0, content_row, content_col + 1, end_row, end_col, {})
  vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col + 1, content)
  vim.fn.winrestview(save)
end

-- Buffer-local settings for TeX
vim.api.nvim_create_autocmd("FileType", {
  group = GRP,
  pattern = { "tex" },
  callback = function(args)
    local buf = args.buf

    -- Buffer-local basics
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.formatoptions:append "t"
    vim.opt_local.textwidth = 80

    -- Textcolor keymaps: <leader>t{b,r,g}
    -- Normal: if inside a \textcolor, switch color; otherwise operator + motion
    -- Visual: always wrap selection
    for key, color in pairs(textcolor_colors) do
      local fname = "v:lua._textcolor_" .. color

      vim.keymap.set("n", "<leader>t" .. key, function()
        if cursor_in_textcolor() then
          change_textcolor(color)
        else
          vim.o.operatorfunc = fname
          vim.api.nvim_feedkeys("g@", "n", false)
        end
      end, { buffer = buf, desc = "\\textcolor{" .. color .. "} (or switch)" })

      vim.keymap.set("x", "<leader>t" .. key, function()
        vim.o.operatorfunc = fname
        return "g@"
      end, { expr = true, buffer = buf, desc = "\\textcolor{" .. color .. "}" })
    end

    -- Remove textcolor wrapper entirely
    vim.keymap.set("n", "<leader>tx", remove_textcolor, { buffer = buf, desc = "Remove \\textcolor wrapper" })

    -- Setup Nabla (conceal settings + keymaps)
    nabla_setup.setup(buf)
  end,
})

-- Re-enable Nabla virtual text after writes (if cleared)
vim.api.nvim_create_autocmd("BufWritePost", {
  group = GRP,
  pattern = { "*.tex", "*.ltx" },
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if ft ~= "tex" or not vim.b[args.buf].nabla_enabled then
      return
    end
    local ok_nabla, nabla = pcall(require, "nabla")
    if ok_nabla then
      nabla.enable_virt()
    end
  end,
})
