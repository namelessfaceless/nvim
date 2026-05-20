-- ~/.config/nvim/lua/custom/language_specific_commands/cadquery.lua
-- Auto-run CadQuery scripts on save, sending output to the OCP viewer.

local GRP = vim.api.nvim_create_augroup("CadQueryViewer", { clear = true })

local cad_venv = vim.fn.expand "~/Documents/cad/.venv/bin/python"
local cad_dir = vim.fn.expand "~/Documents/cad"

local function is_cad_file(filepath)
  return filepath:match("%.py$") and filepath:find(cad_dir, 1, true) == 1
end

local function run_cadquery(buf)
  local filepath = vim.api.nvim_buf_get_name(buf)
  if filepath == "" or not is_cad_file(filepath) then
    return
  end

  vim.notify("Rendering: " .. vim.fn.fnamemodify(filepath, ":t"), vim.log.levels.INFO, { title = "CadQuery" })

  vim.fn.jobstart({ cad_venv, filepath }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data and data[1] ~= "" then
        vim.schedule(function()
          vim.notify(table.concat(data, "\n"), vim.log.levels.INFO, { title = "CadQuery" })
        end)
      end
    end,
    on_stderr = function(_, data)
      if data and data[1] ~= "" then
        local msg = table.concat(data, "\n")
        -- Filter out noisy OCP viewer warnings
        if msg:match("CameraKeep") or msg:match("reset_camera") or msg:match("collapse value") then
          return
        end
        vim.schedule(function()
          vim.notify(msg, vim.log.levels.WARN, { title = "CadQuery" })
        end)
      end
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        if code == 0 then
          vim.notify("Model updated", vim.log.levels.INFO, { title = "CadQuery" })
        else
          vim.notify("Render failed (exit " .. code .. ")", vim.log.levels.ERROR, { title = "CadQuery" })
        end
      end)
    end,
  })
end

-- Auto-run on save for any .py file under ~/Documents/cad/
vim.api.nvim_create_autocmd("BufWritePost", {
  group = GRP,
  pattern = "*.py",
  callback = function(args)
    run_cadquery(args.buf)
  end,
})

-- Manual trigger: <leader>cr (cad render)
vim.api.nvim_create_autocmd("BufEnter", {
  group = GRP,
  pattern = "*.py",
  callback = function(args)
    local filepath = vim.api.nvim_buf_get_name(args.buf)
    if is_cad_file(filepath) then
      vim.keymap.set("n", "<leader>cr", function()
        run_cadquery(args.buf)
      end, { buffer = args.buf, desc = "CadQuery: render model" })
    end
  end,
})
