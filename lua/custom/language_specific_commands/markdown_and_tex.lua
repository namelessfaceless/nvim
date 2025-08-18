-- Efficient Markdown/TeX + Nabla integration
local grp = vim.api.nvim_create_augroup("MarkdownTexWithNabla", { clear = true })

-- 1) Set buffer-local stuff ONCE (spell, textwidth, formatoptions, keymaps) on FileType
vim.api.nvim_create_autocmd("FileType", {
  group = grp,
  pattern = { "markdown", "tex" },
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    -- Buffer-local basics (only once per buffer)
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.formatoptions:append "t"

    if ft == "markdown" then
      vim.opt_local.textwidth = 60
    else -- tex
      vim.opt_local.textwidth = 80
    end

    -- Buffer-local Nabla keymaps (define once)
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
        -- Enable once initially and mark as active
        nabla.enable_virt()
        vim.b[args.buf].nabla_enabled = true
      end
      vim.b[args.buf].nabla_keys = true
    end
  end,
})

-- 2) Window-local conceal settings (apply per window that views the buffer)
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = grp,
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if ft ~= "markdown" and ft ~= "tex" then
      return
    end
    -- Window-local: set each time the buffer is shown in a window
    vim.wo[args.win].conceallevel = 2
    vim.wo[args.win].concealcursor = "ic" -- reveal on hover in normal mode
  end,
})

-- 3) Re-enable Nabla only after writes (some tools clear virt text on save)
vim.api.nvim_create_autocmd("BufWritePost", {
  group = grp,
  pattern = { "*.md", "*.mdx", "*.markdown", "*.tex", "*.ltx" },
  callback = function(args)
    if not vim.b[args.buf].nabla_enabled then
      return
    end
    local ok_nabla, nabla = pcall(require, "nabla")
    if ok_nabla then
      nabla.enable_virt()
    end
  end,
})
