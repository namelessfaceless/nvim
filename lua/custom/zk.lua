-- === Zettelkasten helpers (custom.zk) ===
-- Root + folder layout (with spaces, as requested)
local zk_root = vim.fn.expand "~/Documents/Dane's Vault/Zettelkasten"
local fleeting_dir = zk_root .. "/Fleeting Notes"
local hub_dir = zk_root .. "/Hub Notes"
local permanent_dir = zk_root .. "/Permanent Notes"
local daily_dir = fleeting_dir .. "/Daily" -- assumption: dailies live under Fleeting Notes/Daily

-- ---------- utilities ----------
local function slugify(s)
  s = (s or ""):lower()
  s = s
    :gsub("[^%w%s%-]", "") -- keep letters, digits, space, dash
    :gsub("%s+", "-") -- spaces -> dash
    :gsub("%-+", "-") -- collapse dashes
    :gsub("^%-", "")
    :gsub("%-$", "")
  return s
end

local function iso_utc()
  return os.date "!%Y-%m-%dT%H:%M:%SZ"
end
local function ensure_dir(path)
  vim.fn.mkdir(path, "p")
end
local function starts_with(s, prefix)
  return s:sub(1, #prefix) == prefix
end

-- ---------- front-matter: update `modified:` on save ----------
local function update_modified_in_buffer()
  local api, buf = vim.api, vim.api.nvim_get_current_buf()
  local path = vim.fn.expand "%:p"

  -- Only touch Markdown in your ZK root
  if vim.bo[buf].filetype ~= "markdown" and not path:lower():match "%.md$" then
    return
  end
  if not starts_with(path, zk_root) then
    return
  end

  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  if #lines < 1 or lines[1] ~= "---" then
    return
  end

  -- find closing '---'
  local fm_end
  for i = 2, math.min(#lines, 200) do
    if lines[i] == "---" then
      fm_end = i
      break
    end
  end
  if not fm_end then
    return
  end

  -- find or insert modified:
  local modified_idx
  for i = 2, fm_end - 1 do
    if lines[i]:match "^modified:%s" then
      modified_idx = i
      break
    end
  end

  local now = "modified: " .. iso_utc()
  if modified_idx then
    if lines[modified_idx] ~= now then
      lines[modified_idx] = now
      api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    end
  else
    table.insert(lines, fm_end, now)
    api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end
end

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.md",
  callback = update_modified_in_buffer,
  desc = "ZK: auto-update YAML modified: on save",
})

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

-- ---------- :ZkNewPermanent ----------
local function new_permanent_note(opts)
  local title = table.concat(opts.fargs or {}, " ")
  if title == "" then
    title = vim.fn.input "Permanent note title: "
  end
  if not title or title == "" then
    vim.notify("Aborted: empty title.", vim.log.levels.WARN)
    return
  end

  local id = os.date "%Y%m%d%H%M%S"
  local slug = slugify(title)
  local filename = string.format("%s-%s.md", id, slug)

  ensure_dir(permanent_dir)
  local path = permanent_dir .. "/" .. filename

  local created = iso_utc()
  local ok = write_if_missing(path, {
    "---",
    "id: " .. id,
    "title: " .. title,
    "type: permanent",
    "created: " .. created,
    "modified: " .. created,
    "tags: []",
    "---",
    "",
    "# " .. title,
    "",
  })
  if ok then
    vim.cmd.edit(path)
  end
end

vim.api.nvim_create_user_command(
  "ZkNewPermanent",
  new_permanent_note,
  { nargs = "*", desc = "Create a new permanent ZK note and open it" }
)

-- ---------- :ZkNewDaily ----------
-- Opens today's daily note if it exists; otherwise creates it (under Fleeting Notes/Daily).
local function new_daily_note()
  local today = os.date "%Y-%m-%d"
  local title = "Daily — " .. today
  local fname = today .. ".md"

  ensure_dir(daily_dir)
  local path = daily_dir .. "/" .. fname

  local created = iso_utc()
  local ok = write_if_missing(path, {
    "---",
    "id: " .. today, -- simple id for dailies
    "title: " .. title,
    "type: daily",
    "created: " .. created,
    "modified: " .. created,
    "tags: [daily]",
    "---",
    "",
    "# " .. title,
    "",
    "## Quick capture",
    "",
    "- ",
    "",
    "## Tasks",
    "",
    "- [ ] ",
    "",
    "## Notes",
    "",
  })
  if ok then
    vim.cmd.edit(path)
  end
end

vim.api.nvim_create_user_command("ZkNewDaily", new_daily_note, { desc = "Open or create today's ZK daily note" })

-- ---------- :ZkNewHub ----------
-- Hub/Structure note (MOC): great as an index/overview for a topic or project.
-- File naming: HUB-YYYYMMDDHHMMSS-<slug>.md (easy to spot + sortable)
local function new_hub_note(opts)
  local title = table.concat(opts.fargs or {}, " ")
  if title == "" then
    title = vim.fn.input "Hub note title: "
  end
  if not title or title == "" then
    vim.notify("Aborted: empty title.", vim.log.levels.WARN)
    return
  end

  local id = "HUB-" .. os.date "%Y%m%d%H%M%S"
  local slug = slugify(title)
  local filename = string.format("%s-%s.md", id, slug)

  ensure_dir(hub_dir)
  local path = hub_dir .. "/" .. filename

  local created = iso_utc()
  -- A practical hub template: overview, TOC, backlinks/related, and open questions.
  local ok = write_if_missing(path, {
    "---",
    "id: " .. id,
    "title: " .. title,
    "type: hub",
    "created: " .. created,
    "modified: " .. created,
    "tags: [hub]",
    "aliases: []",
    "---",
    "",
    "# " .. title,
    "",
    "> Brief purpose/definition of this hub.",
    "",
    "## Overview",
    "",
    "- ",
    "",
    "## Contents (map of notes)",
    "",
    "- [[ ]]  ",
    "- [[ ]]  ",
    "- [[ ]]  ",
    "",
    "## Permanent seeds (key ideas)",
    "",
    "- [[ ]]  ",
    "",
    "## Related hubs",
    "",
    "- [[ ]]  ",
    "",
    "## Sources / Literature",
    "",
    "- ",
    "",
    "## Open questions / Next actions",
    "",
    "- [ ] ",
    "",
  })
  if ok then
    vim.cmd.edit(path)
  end
end

vim.api.nvim_create_user_command(
  "ZkNewHub",
  new_hub_note,
  { nargs = "*", desc = "Create a new hub (structure) note and open it" }
)

-- ---------- keymaps ----------
-- <leader>zn  : new permanent
-- <leader>zd  : today's daily
-- <leader>zh  : new hub
vim.keymap.set("n", "<leader>zn", ":ZkNewPermanent ", { desc = "ZK: New permanent note" })
vim.keymap.set("n", "<leader>zd", ":ZkNewDaily<CR>", { desc = "ZK: Open/create today's daily" })
vim.keymap.set("n", "<leader>zh", ":ZkNewHub ", { desc = "ZK: New hub (structure) note" })
