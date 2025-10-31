-- === Journal helpers ===
local journal_dir = vim.fn.expand "~/Documents/Dane's Vault/Writing/Journal"

-- ---------- utilities ----------
local function ensure_dir(path)
  vim.fn.mkdir(path, "p")
end

local function iso_utc()
  return os.date "!%Y-%m-%dT%H:%M:%SZ"
end

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
local function new_journal_note()
  local timestamp = os.date "%Y%m%d-%H%M%S"
  local date_title = os.date "%A, %B %d, %Y - %I:%M %p"
  local filename = "JRNL-" .. timestamp .. ".md"

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
    vim.cmd "normal! Go"
  end
end

-- ---------- :JrnlCompile ----------
local function compile_journal()
  -- Change to journal directory
  local original_dir = vim.fn.getcwd()
  vim.cmd("cd " .. vim.fn.fnameescape(journal_dir))

  -- Find journal files using simple glob in current directory
  local journal_files = vim.fn.glob("JRNL-*.md", false, true)

  if #journal_files == 0 then
    vim.notify("No journal entries found", vim.log.levels.WARN)
    vim.cmd("cd " .. vim.fn.fnameescape(original_dir))
    return
  end

  -- Read config
  local config_file = "journal_config.txt"
  if vim.fn.filereadable(config_file) == 0 then
    local default_config = {
      "# Journal Config",
      "pdf-engine=xelatex",
      "V geometry:margin=1in",
      "V fontsize=11pt",
      "toc",
      "V title=My Journal",
      "V author=Dane",
      "V date=" .. os.date "%B %Y",
    }
    local fh = io.open(config_file, "w")
    if fh then
      fh:write(table.concat(default_config, "\n"))
      fh:close()
      vim.notify("Created journal config file", vim.log.levels.INFO)
    end
  end

  -- Parse config
  local config_args = {}
  local fh = io.open(config_file, "r")
  if fh then
    for line in fh:lines() do
      local trimmed = line:match "^%s*(.-)%s*$"
      if trimmed ~= "" and not trimmed:match "^#" then
        if trimmed:match "^V " then
          local var_content = trimmed:match "^V (.+)"
          table.insert(config_args, "-V")
          table.insert(config_args, var_content)
        else
          table.insert(config_args, "--" .. trimmed)
        end
      end
    end
    fh:close()
  end

  -- Sort files
  table.sort(journal_files)

  -- Build command as table to avoid shell escaping issues
  local cmd_parts = { "pandoc" }

  -- Add input files
  for _, file in ipairs(journal_files) do
    table.insert(cmd_parts, file)
  end

  -- Add config args
  for _, arg in ipairs(config_args) do
    table.insert(cmd_parts, arg)
  end

  -- Add output
  table.insert(cmd_parts, "-o")
  table.insert(cmd_parts, "compiled_journal.pdf")

  vim.notify("Compiling " .. #journal_files .. " journal entries...", vim.log.levels.INFO)

  -- Run pandoc using vim.system (avoids shell entirely)
  local result = vim.system(cmd_parts):wait()

  -- Return to original directory
  vim.cmd("cd " .. vim.fn.fnameescape(original_dir))

  if result.code == 0 then
    vim.notify("Journal compiled successfully!", vim.log.levels.INFO)
  else
    local error_msg = result.stderr or "Unknown error"
    vim.notify("Compilation failed: " .. error_msg, vim.log.levels.ERROR)
  end
end

vim.api.nvim_create_user_command("JrnlNew", new_journal_note, { desc = "Create new journal entry" })
vim.api.nvim_create_user_command("JrnlCompile", compile_journal, { desc = "Compile journal to PDF" })

vim.keymap.set("n", "<leader>jn", ":JrnlNew<CR>", { desc = "Journal: New entry" })
vim.keymap.set("n", "<leader>jc", ":JrnlCompile<CR>", { desc = "Journal: Compile to PDF" })
