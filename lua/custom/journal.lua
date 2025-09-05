-- === Journal helpers ===
local journal_dir = vim.fn.expand "~/Documents/Dane's Vault/Writing/Journal"

-- ---------- utilities ----------
local function ensure_dir(path)
  vim.fn.mkdir(path, "p")
end

local function iso_utc()
  return os.date "!%Y-%m-%dT%H:%M:%SZ"
end

-- ---------- create file helper ----------
local function write_if_missing(path, lines)
  if vim.fn.filereadable(path) == 0 then
    local fh = io.open(path, "w")
    if not fh then
      vim.notify("Failed to create file at " .. path, vim.log.levels.ERROR)
      return false
    end
    fh:write(table.concat(lines, "\n"))
    fh:close()
  end
  return true
end

-- ---------- :JrnlNew ----------
-- Creates a new journal entry with JRNL-YYYYMMDD-HHMMSS.md format
local function new_journal_note()
  local timestamp = os.date "%Y%m%d-%H%M%S"
  local date_title = os.date "%A, %B %d, %Y - %I:%M %p"
  local filename = string.format("JRNL-%s.md", timestamp)

  ensure_dir(journal_dir)
  local path = journal_dir .. "/" .. filename

  local created = iso_utc()
  local ok = write_if_missing(path, {
    "---",
    "id: JRNL-" .. timestamp,
    "title: " .. date_title,
    "type: journal",
    "created: " .. created,
    "modified: " .. created,
    "tags: [journal]",
    "---",
    "",
    "# " .. date_title,
    "",
    "",
  })
  if ok then
    vim.cmd.edit(path)
    -- Position cursor after the title for immediate writing
    vim.cmd "normal! Go"
  end
end

vim.api.nvim_create_user_command("JrnlNew", new_journal_note, { desc = "Create a new journal entry and open it" })

-- ---------- :JrnlCompile ----------
-- Compiles all JRNL-*.md files into a single PDF using pandoc
local function compile_journal()
  local config_file = journal_dir .. "/journal_config.txt"

  -- Create default config if it doesn't exist
  if vim.fn.filereadable(config_file) == 0 then
    local default_config = {
      "# Journal Compilation Config",
      "# Edit this file to customize your journal PDF output",
      "",
      "# Pandoc options (one per line, without leading dashes)",
      "pdf-engine=xelatex",
      "V geometry:margin=1in",
      "V mainfont=Times New Roman",
      "V fontsize=11pt",
      "toc",
      "toc-depth=2",
      "",
      "# Title page info",
      "V title=My Journal",
      "V author=Dane",
      "V date=" .. os.date "%B %Y",
    }

    local fh = io.open(config_file, "w")
    if fh then
      fh:write(table.concat(default_config, "\n"))
      fh:close()
      vim.notify("Created default journal config at: " .. config_file, vim.log.levels.INFO)
    end
  end

  -- Read config file
  local config_lines = {}
  local fh = io.open(config_file, "r")
  if fh then
    for line in fh:lines() do
      local trimmed = line:match "^%s*(.-)%s*$" -- trim whitespace
      if trimmed ~= "" and not trimmed:match "^#" then
        table.insert(config_lines, "--" .. trimmed)
      end
    end
    fh:close()
  end

  -- Build pandoc command
  local config_args = table.concat(config_lines, " ")
  local output_file = journal_dir .. "/compiled_journal.pdf"
  print(journal_dir)
  local cmd = string.format(
    "cd '%s' && find . -name 'JRNL-*.md' | sort | xargs cat | pandoc %s -o '%s'",
    journal_dir,
    config_args,
    output_file
  )

  vim.notify("Compiling journal entries...", vim.log.levels.INFO)

  -- Run the command
  local result = vim.fn.system(cmd)
  local exit_code = vim.v.shell_error

  if exit_code == 0 then
    vim.notify("Journal compiled successfully: " .. output_file, vim.log.levels.INFO)
  else
    vim.notify("Journal compilation failed: " .. result, vim.log.levels.ERROR)
  end
end

vim.api.nvim_create_user_command("JrnlCompile", compile_journal, { desc = "Compile all JRNL-*.md files into PDF" })

-- ---------- keymaps ----------
-- Add to your existing keymaps section
vim.keymap.set("n", "<leader>jn", ":JrnlNew<CR>", { desc = "Journal: New entry" })
vim.keymap.set("n", "<leader>jc", ":JrnlCompile<CR>", { desc = "Journal: Compile to PDF" })
