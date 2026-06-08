-- git_quickpush.lua
-- A tiny helper that stages all changes, auto-commits with a generated message,
-- and pushes the current repo (based on Neovim's *current working directory*).
--
-- Commands:
--   :GitQuickPush
--   :GitQuickPush small fix to hub template
--
-- Keymap:
--   <leader>gp

local M = {}

-- --- helpers ---------------------------------------------------------------

-- Run a command synchronously and get code/stdout/stderr
local function run(cmd, cwd)
  -- Prefer Neovim 0.10+ API
  if vim.system then
    local res = vim.system(cmd, { cwd = cwd }):wait()
    return res.code or 0, (res.stdout or ""), (res.stderr or "")
  end
  -- Fallback for older Neovim
  local out = vim.fn.systemlist(table.concat(cmd, " "), cwd) -- not perfect quoting, but fine for git
  local code = vim.v.shell_error
  return code, table.concat(out or {}, "\n"), ""
end

-- Find the git repo root from a given working directory (or cwd if nil).
local function git_root(from_dir)
  local start = from_dir or vim.fn.getcwd()
  local code, out = run({ "git", "rev-parse", "--show-toplevel" }, start)
  if code ~= 0 or not out or out == "" then
    return nil
  end
  -- Trim trailing newline(s)
  out = out:gsub("%s+$", "")
  return out
end

-- Build a commit message and a short preview of changes
local function build_commit_message(repo, extra_words, preview_limit)
  preview_limit = preview_limit or 8
  local code, status = run({ "git", "status", "--porcelain" }, repo)
  local lines = {}
  if code == 0 and status and #status > 0 then
    for line in status:gmatch "[^\r\n]+" do
      table.insert(lines, line)
    end
  end
  local count = #lines
  local ts = os.date "%Y-%m-%d %H:%M:%S"
  local msg = string.format("Auto sync: %s (%d files changed)", ts, count)
  if extra_words and extra_words:match "%S" then
    msg = msg .. " — " .. extra_words
  end
  local preview = {}
  for i = 1, math.min(preview_limit, count) do
    preview[i] = lines[i]
  end
  return msg, preview, count
end

-- --- main action -----------------------------------------------------------

local function quick_push(opts)
  -- 0) Resolve repo root from Neovim's *current* working directory
  local cwd = vim.fn.getcwd()
  local repo = git_root(cwd)
  if not repo then
    vim.notify("Not inside a git repository (cwd: " .. cwd .. ")", vim.log.levels.ERROR, { title = "Git Quick Push" })
    return
  end

  -- 1) Stage everything
  do
    local code, _, err = run({ "git", "add", "-A" }, repo)
    if code ~= 0 then
      vim.notify("git add failed:\n" .. (err or ""), vim.log.levels.ERROR, { title = "Git Quick Push" })
      return
    end
  end

  -- 2) Compose commit message (+ optional words from :GitQuickPush args)
  local extra = table.concat(opts.fargs or {}, " ")
  local msg, preview, count = build_commit_message(repo, extra, 8)

  -- 3) If there are changes, commit; otherwise skip straight to push
  if count > 0 then
    local args = { "git", "commit", "-m", msg }
    for _, p in ipairs(preview) do
      table.insert(args, "-m")
      table.insert(args, p)
    end
    local code, out, err = run(args, repo)
    if code ~= 0 then
      vim.notify(
        "git commit failed:\n" .. (err ~= "" and err or out),
        vim.log.levels.ERROR,
        { title = "Git Quick Push" }
      )
      return
    end
  else
    vim.notify("No changes to commit; pushing anyway…", vim.log.levels.INFO, { title = "Git Quick Push" })
  end

  -- 4) Push to the current branch’s upstream
  do
    local code, out, err = run({ "git", "push" }, repo)
    if code ~= 0 then
      vim.notify("git push failed:\n" .. (err ~= "" and err or out), vim.log.levels.ERROR, { title = "Git Quick Push" })
      return
    end
  end

  -- 5) Done
  local summary = (count > 0) and ("Committed & pushed:\n" .. msg) or "Pushed (no new commits)."
  vim.notify(summary, vim.log.levels.INFO, { title = "Git Quick Push" })
end

-- --- public command & keymap ----------------------------------------------

-- :GitQuickPush [optional words...]
vim.api.nvim_create_user_command(
  "GitQuickPush",
  quick_push,
  { nargs = "*", desc = "Stage all, auto-commit, and push for the repo at current working directory" }
)

-- Optional keymap
vim.keymap.set("n", "<leader>gp", ":GitQuickPush<CR>", { desc = "Git: quick add+commit+push (cwd repo)" })

return M
