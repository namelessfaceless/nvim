-- Taskwarrior integration for Neovim
-- Add this to your ~/.config/nvim/init.lua or create a separate plugin file

-- Basic task management commands
vim.api.nvim_create_user_command("TaskAdd", function(opts)
  local task_desc = opts.args
  if task_desc == "" then
    task_desc = vim.fn.input "Task description: "
  end
  vim.fn.system("task add " .. vim.fn.shellescape(task_desc))
  print("Task added: " .. task_desc)
end, { nargs = "*", desc = "Add a new task" })

vim.api.nvim_create_user_command("TaskList", function()
  local output = vim.fn.system "task list"
  vim.cmd "new"
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n"))
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.modifiable = false
  vim.wo.number = false
  vim.wo.relativenumber = false
end, { desc = "Show task list in new buffer" })

vim.api.nvim_create_user_command("TaskNext", function()
  local output = vim.fn.system "task next"
  print(vim.trim(output))
end, { desc = "Show next tasks" })

vim.api.nvim_create_user_command("TaskEdit", function(opts)
  local task_id = opts.args
  if task_id == "" then
    task_id = vim.fn.input "Task ID to edit: "
  end
  if task_id ~= "" then
    vim.fn.system("task " .. task_id .. " edit")
    print("Edited task " .. task_id)
  end
end, { nargs = "?", desc = "Edit a task by ID" })

vim.api.nvim_create_user_command("TaskDone", function(opts)
  local task_id = opts.args
  if task_id == "" then
    task_id = vim.fn.input "Task ID to complete: "
  end
  if task_id ~= "" then
    vim.fn.system("task " .. task_id .. " done")
    print("Task " .. task_id .. " completed!")
  end
end, { nargs = "?", desc = "Mark task as done" })

vim.api.nvim_create_user_command("TaskModify", function(opts)
  local args = vim.split(opts.args, " ", { trimempty = true })
  if #args < 2 then
    local task_id = vim.fn.input "Task ID: "
    local modification = vim.fn.input "Modification (e.g., 'priority:H', '+urgent'): "
    if task_id ~= "" and modification ~= "" then
      vim.fn.system("task " .. task_id .. " modify " .. modification)
      print("Modified task " .. task_id)
    end
  else
    local task_id = args[1]
    local modification = table.concat(args, " ", 2)
    vim.fn.system("task " .. task_id .. " modify " .. modification)
    print("Modified task " .. task_id .. " with: " .. modification)
  end
end, { nargs = "*", desc = "Modify a task" })

-- Project and context commands
vim.api.nvim_create_user_command("TaskProject", function(opts)
  local project = opts.args
  if project == "" then
    local output = vim.fn.system "task projects"
    print(output)
  else
    local output = vim.fn.system("task project:" .. project .. " list")
    vim.cmd "new"
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n"))
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.modifiable = false
  end
end, { nargs = "?", desc = "Show projects or filter by project" })

-- Advanced: Add task from visual selection
vim.keymap.set("v", "<leader>ta", function()
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
  local selected_text = table.concat(lines, " "):gsub("%s+", " ")
  vim.fn.system("task add " .. vim.fn.shellescape(selected_text))
  print("Task added from selection: " .. selected_text)
end, { desc = "Add task from visual selection" })

-- Key mappings (using <leader>t prefix for taskwarrior)
vim.keymap.set("n", "<leader>ta", ":TaskAdd<CR>", { desc = "Add task" })
vim.keymap.set("n", "<leader>tl", ":TaskList<CR>", { desc = "List tasks" })
vim.keymap.set("n", "<leader>tn", ":TaskNext<CR>", { desc = "Show next tasks" })
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
    vim.fn.system("task " .. task_id .. " modify priority:H")
    print("Set task " .. task_id .. " to high priority")
  end
end, { desc = "Set task to high priority" })

vim.keymap.set("n", "<leader>tu", function()
  local task_id = vim.fn.input "Task ID to add urgent tag: "
  if task_id ~= "" then
    vim.fn.system("task " .. task_id .. " modify +urgent")
    print("Added urgent tag to task " .. task_id)
  end
end, { desc = "Add urgent tag to task" })

-- Show task summary in statusline or floating window
vim.api.nvim_create_user_command("TaskSummary", function()
  local output = vim.fn.system "task summary"
  local lines = vim.split(output, "\n")

  -- Create floating window
  local width = 60
  local height = #lines + 2
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
end, { desc = "Show task summary in floating window" })

vim.keymap.set("n", "<leader>ts", ":TaskSummary<CR>", { desc = "Show task summary" })

print "Taskwarrior integration loaded! Use <leader>t* commands or :Task* commands"
