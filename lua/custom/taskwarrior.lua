-- Taskwarrior integration for Neovim with clean notifications
-- Add this to your ~/.config/nvim/init.lua or create a separate plugin file

-- Helper function for clean error handling with notifications
local function run_task_command(cmd, success_msg, error_prefix)
  local result = vim.fn.system(cmd)
  if vim.v.shell_error == 0 then
    if success_msg then
      vim.notify(success_msg, vim.log.levels.INFO)
    end
    return true, result
  else
    vim.notify((error_prefix or "Error") .. ": " .. vim.trim(result), vim.log.levels.ERROR)
    return false, result
  end
end

-- Basic task management commands
vim.api.nvim_create_user_command("TaskAdd", function(opts)
  local task_desc = opts.args
  if task_desc == "" then
    task_desc = vim.fn.input "Task description: "
  end
  if task_desc ~= "" then
    run_task_command("task add " .. task_desc, "Task added successfully", "Error adding task")
  end
end, { nargs = "*", desc = "Add a new task" })

vim.api.nvim_create_user_command("TaskList", function()
  local success, output = run_task_command("task list", nil, "Error listing tasks")
  if success then
    vim.cmd "new"
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n"))
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.modifiable = false
    vim.wo.number = false
    vim.wo.relativenumber = false
    -- Set a descriptive buffer name
    vim.api.nvim_buf_set_name(0, "TaskWarrior List (All)")
  end
end, { desc = "Show all pending tasks in new buffer" })

vim.api.nvim_create_user_command("TaskNext", function()
  local success, output = run_task_command("task next limit:10", nil, "Error getting next tasks")
  if success then
    local lines = vim.split(vim.trim(output), "\n")
    -- Filter out empty lines
    local clean_lines = {}
    for _, line in ipairs(lines) do
      if line ~= "" and not line:match "^%s*$" then
        table.insert(clean_lines, line)
      end
    end

    if #clean_lines > 0 then
      -- Create floating window for next tasks
      local width = math.min(math.max(80, vim.o.columns - 20), 120)
      local height = math.min(#clean_lines + 2, 25)
      local row = math.floor((vim.o.lines - height) / 2)
      local col = math.floor((vim.o.columns - width) / 2)

      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, clean_lines)

      local opts = {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = " Next Tasks ",
        title_pos = "center",
      }

      vim.api.nvim_open_win(buf, true, opts)
      vim.bo[buf].modifiable = false
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf })
      vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf })
    else
      vim.notify("No pending tasks", vim.log.levels.WARN)
    end
  end
end, { desc = "Show next 10 highest priority tasks in floating window" })

vim.api.nvim_create_user_command("TaskEdit", function(opts)
  local task_id = opts.args
  if task_id == "" then
    task_id = vim.fn.input "Task ID to edit: "
  end
  if task_id ~= "" then
    run_task_command("task " .. task_id .. " edit", "Edited task " .. task_id, "Error editing task")
  end
end, { nargs = "?", desc = "Edit a task by ID" })

vim.api.nvim_create_user_command("TaskDone", function(opts)
  local task_id = opts.args
  if task_id == "" then
    task_id = vim.fn.input "Task ID to complete: "
  end
  if task_id ~= "" then
    run_task_command("task " .. task_id .. " done", "Task " .. task_id .. " completed!", "Error completing task")
  end
end, { nargs = "?", desc = "Mark task as done" })

vim.api.nvim_create_user_command("TaskModify", function(opts)
  local args = vim.split(opts.args, " ", { trimempty = true })
  if #args < 2 then
    local task_id = vim.fn.input "Task ID: "
    local modification = vim.fn.input "Modification (e.g., 'priority:H', '+urgent'): "
    if task_id ~= "" and modification ~= "" then
      run_task_command(
        "task " .. task_id .. " modify " .. modification,
        "Modified task " .. task_id,
        "Error modifying task"
      )
    end
  else
    local task_id = args[1]
    local modification = table.concat(args, " ", 2)
    run_task_command(
      "task " .. task_id .. " modify " .. modification,
      "Modified task " .. task_id,
      "Error modifying task"
    )
  end
end, { nargs = "*", desc = "Modify a task" })

vim.api.nvim_create_user_command("TaskStart", function(opts)
  local task_id = opts.args
  if task_id == "" then
    task_id = vim.fn.input "Task ID to start: "
  end
  if task_id ~= "" then
    run_task_command("task " .. task_id .. " start", "Started task " .. task_id, "Error starting task")
  end
end, { nargs = "?", desc = "Start working on a task" })

vim.api.nvim_create_user_command("TaskStop", function(opts)
  local task_id = opts.args
  if task_id == "" then
    -- If no ID provided, stop the active task
    local success, active_output = run_task_command("task +ACTIVE ids", nil, "Error finding active tasks")
    if success then
      local active_id = vim.trim(active_output)
      if active_id ~= "" then
        run_task_command("task " .. active_id .. " stop", "Stopped active task " .. active_id, "Error stopping task")
      else
        vim.notify("No active task to stop", vim.log.levels.WARN)
      end
    end
  else
    run_task_command("task " .. task_id .. " stop", "Stopped task " .. task_id, "Error stopping task")
  end
end, { nargs = "?", desc = "Stop working on a task" })

vim.api.nvim_create_user_command("TaskActive", function()
  local success, output = run_task_command("task +ACTIVE list", nil, "Error getting active tasks")
  if success then
    if vim.trim(output) == "" or output:match "No matches" then
      vim.notify("No active tasks", vim.log.levels.WARN)
    else
      vim.cmd "new"
      vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n"))
      vim.bo.buftype = "nofile"
      vim.bo.bufhidden = "wipe"
      vim.bo.modifiable = false
      vim.wo.number = false
      vim.wo.relativenumber = false
    end
  end
end, { desc = "Show active tasks" })

-- Project and context commands
vim.api.nvim_create_user_command("TaskProject", function(opts)
  local project = opts.args
  if project == "" then
    local success, output = run_task_command("task projects", nil, "Error listing projects")
    if success then
      vim.notify(output, vim.log.levels.INFO)
    end
  else
    local success, output = run_task_command("task project:" .. project .. " list", nil, "Error filtering by project")
    if success then
      vim.cmd "new"
      vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n"))
      vim.bo.buftype = "nofile"
      vim.bo.bufhidden = "wipe"
      vim.bo.modifiable = false
    end
  end
end, { nargs = "?", desc = "Show projects or filter by project" })

-- Advanced: Add task from visual selection
vim.keymap.set("v", "<leader>ta", function()
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
  local selected_text = table.concat(lines, " "):gsub("%s+", " ")
  if selected_text ~= "" then
    run_task_command("task add " .. selected_text, "Task added from selection", "Error adding task from selection")
  end
end, { desc = "Add task from visual selection" })

-- Key mappings (using <leader>t prefix for taskwarrior)
vim.keymap.set("n", "<leader>ta", ":TaskAdd<CR>", { desc = "Add task" })
vim.keymap.set("n", "<leader>tl", ":TaskList<CR>", { desc = "List all tasks" })
vim.keymap.set("n", "<leader>tn", ":TaskNext<CR>", { desc = "Show next 10 tasks" })
vim.keymap.set("n", "<leader>te", ":TaskEdit<CR>", { desc = "Edit task" })
vim.keymap.set("n", "<leader>td", ":TaskDone<CR>", { desc = "Mark task done" })
vim.keymap.set("n", "<leader>tm", ":TaskModify<CR>", { desc = "Modify task" })
vim.keymap.set("n", "<leader>tp", ":TaskProject<CR>", { desc = "Show projects" })
vim.keymap.set("n", "<leader>tS", ":TaskStart<CR>", { desc = "Start task" })
vim.keymap.set("n", "<leader>tT", ":TaskStop<CR>", { desc = "Stop task" })
vim.keymap.set("n", "<leader>tA", ":TaskActive<CR>", { desc = "Show active tasks" })

-- Quick shortcuts for common modifications
vim.keymap.set("n", "<leader>tH", function()
  local task_id = vim.fn.input "Task ID for high priority: "
  if task_id ~= "" then
    run_task_command(
      "task " .. task_id .. " modify priority:H",
      "Set task " .. task_id .. " to high priority",
      "Error setting priority"
    )
  end
end, { desc = "Set task to high priority" })

vim.keymap.set("n", "<leader>tu", function()
  local task_id = vim.fn.input "Task ID to add urgent tag: "
  if task_id ~= "" then
    run_task_command(
      "task " .. task_id .. " modify +urgent",
      "Added urgent tag to task " .. task_id,
      "Error adding urgent tag"
    )
  end
end, { desc = "Add urgent tag to task" })

-- Show task summary in floating window
vim.api.nvim_create_user_command("TaskSummary", function()
  local success, output = run_task_command("task summary", nil, "Error getting task summary")
  if success then
    local lines = vim.split(output, "\n")

    -- Create floating window
    local width = 60
    local height = math.min(#lines + 2, 20)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    local opts = {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = "rounded",
      title = " Task Summary ",
      title_pos = "center",
    }

    vim.api.nvim_open_win(buf, true, opts)
    vim.bo[buf].modifiable = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf })
  end
end, { desc = "Show task summary in floating window" })

vim.keymap.set("n", "<leader>ts", ":TaskSummary<CR>", { desc = "Show task summary" })

-- Use a timer to show the load message after everything initializes
vim.defer_fn(function()
  vim.notify("Taskwarrior integration loaded! Use <leader>t* commands", vim.log.levels.INFO)
end, 100)
