-- ~/.config/nvim/lua/custom/language_specific_commands/markdown_and_tex.lua

local GRP = vim.api.nvim_create_augroup("MarkdownTexWithNabla", { clear = true })

-- 1) Buffer-local settings: set ONCE per buffer
vim.api.nvim_create_autocmd("FileType", {
  group = GRP,
  pattern = { "markdown", "tex" },
  callback = function(args)
    local ft = vim.bo[args.buf].filetype

    -- Buffer-local basics
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.formatoptions:append "t"

    if ft == "markdown" then
      vim.opt_local.textwidth = 60
    else
      vim.opt_local.textwidth = 80
    end

    -- Buffer-local conceal (instead of window-local)
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = "ic" -- reveal on hover in normal mode

    -- Buffer-local Nabla keymaps (define once per buffer)
    if not vim.b[args.buf].nabla_keys then
      local ok_nabla, nabla = pcall(require, "nabla")
      if ok_nabla then
        local bufopts = { buffer = args.buf, silent = true }
        vim.keymap.set("n", "<leader>mnve", function()
          nabla.enable_virt()
        end, vim.tbl_extend("force", bufopts, { desc = "Nabla: render math (virtual text)" }))
        vim.keymap.set("n", "<leader>mnvd", function()
          nabla.disable_virt()
        end, vim.tbl_extend("force", bufopts, { desc = "Nabla: clear rendering" }))
        vim.keymap.set("n", "<leader>mnp", function()
          nabla.popup()
        end, vim.tbl_extend("force", bufopts, { desc = "Nabla: popup under cursor" }))

        -- initial enable
        nabla.enable_virt()
        vim.b[args.buf].nabla_enabled = true
      end
      vim.b[args.buf].nabla_keys = true
    end
  end,
})

-- 2) Re-enable Nabla virtual text after writes (if cleared)
vim.api.nvim_create_autocmd("BufWritePost", {
  group = GRP,
  pattern = { "*.md", "*.mdx", "*.markdown", "*.tex", "*.ltx" },
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if (ft ~= "markdown" and ft ~= "tex") or not vim.b[args.buf].nabla_enabled then
      return
    end
    local ok_nabla, nabla = pcall(require, "nabla")
    if ok_nabla then
      nabla.enable_virt()
    end
  end,
})
