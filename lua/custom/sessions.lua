-- Simple named-session management: write / read / delete.
-- Sessions are plain :mksession files (so 'sessionoptions' governs content)
-- stored under one directory. No automatic save/restore.

local session_dir = vim.fs.normalize(vim.fn.stdpath "data") .. "/sessions/"
vim.fn.mkdir(session_dir, "p")

local function session_path(name)
  return session_dir .. name .. ".vim"
end

local function list_sessions()
  local names = {}
  for _, path in ipairs(vim.fn.glob(session_dir .. "*.vim", true, true)) do
    table.insert(names, vim.fn.fnamemodify(path, ":t:r"))
  end
  return names
end

local function write_session(name)
  if name == "" then
    name = vim.fn.input "Session name: "
  end
  if name == "" then
    vim.notify("Session write aborted: no name given.", vim.log.levels.WARN)
    return
  end
  vim.cmd("mksession! " .. vim.fn.fnameescape(session_path(name)))
  vim.notify("Session saved: " .. name, vim.log.levels.INFO)
end

local function read_session(name)
  local function load(n)
    local path = session_path(n)
    if vim.fn.filereadable(path) == 0 then
      vim.notify("No session named: " .. n, vim.log.levels.ERROR)
      return
    end
    vim.cmd("source " .. vim.fn.fnameescape(path))
  end
  if name ~= "" then
    load(name)
  else
    vim.ui.select(list_sessions(), { prompt = "Load session:" }, function(choice)
      if choice then
        load(choice)
      end
    end)
  end
end

local function delete_session(name)
  local function del(n)
    local path = session_path(n)
    if vim.fn.filereadable(path) == 0 then
      vim.notify("No session named: " .. n, vim.log.levels.ERROR)
      return
    end
    vim.fn.delete(path)
    vim.notify("Session deleted: " .. n, vim.log.levels.INFO)
  end
  if name ~= "" then
    del(name)
  else
    vim.ui.select(list_sessions(), { prompt = "Delete session:" }, function(choice)
      if choice then
        del(choice)
      end
    end)
  end
end

local function complete_sessions(arg_lead)
  return vim.tbl_filter(function(name)
    return name:find(arg_lead, 1, true) == 1
  end, list_sessions())
end

vim.api.nvim_create_user_command("SessionWrite", function(o)
  write_session(o.args)
end, { nargs = "?", desc = "Write current session (prompts for name if omitted)" })

vim.api.nvim_create_user_command("SessionRead", function(o)
  read_session(o.args)
end, { nargs = "?", complete = complete_sessions, desc = "Read a session (picker if name omitted)" })

vim.api.nvim_create_user_command("SessionDelete", function(o)
  delete_session(o.args)
end, { nargs = "?", complete = complete_sessions, desc = "Delete a session (picker if name omitted)" })
