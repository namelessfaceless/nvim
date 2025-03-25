-- Global variables to store the MATLAB terminal buffer and job ID
local matlab_term_buf = nil
local matlab_term_job = nil

-- Create the "RunMatlab" user command
vim.api.nvim_create_user_command("RunMatlab", function()
  -- Get the absolute path of the current file
  local file = vim.fn.expand "%:p"
  -- Escape single quotes by doubling them for MATLAB's string literal.
  local matlab_file = file:gsub("'", "''")
  -- Construct the command to run MATLAB in batch mode, executing the current file.
  local cmd = "matlab -batch \"run('" .. matlab_file .. "')\""

  -- If we already have a MATLAB terminal and it's valid, reuse it.
  if matlab_term_buf and vim.api.nvim_buf_is_valid(matlab_term_buf) and matlab_term_job then
    -- Check if the terminal buffer is visible in any window.
    local wins = vim.fn.win_findbuf(matlab_term_buf)
    if #wins == 0 then
      -- If not visible, open it in a vertical split.
      vim.cmd "split"
      vim.cmd("buffer " .. matlab_term_buf)
    else
      -- Otherwise, switch focus to that window.
      vim.api.nvim_set_current_win(wins[1])
    end
    -- Send the MATLAB command to the terminal. (You can add a clear command here if desired.)
    vim.api.nvim_chan_send(matlab_term_job, cmd .. "\n")
  else
    -- If the MATLAB terminal doesn't exist, open a new vertical split terminal.
    vim.cmd "split"
    vim.cmd "terminal"
    -- Store the terminal buffer and job ID for future reuse.
    matlab_term_buf = vim.api.nvim_get_current_buf()
    matlab_term_job = vim.b.terminal_job_id
    -- Optionally, rename the terminal buffer for clarity.
    vim.api.nvim_buf_set_name(matlab_term_buf, "MATLAB Output")
    -- Send the MATLAB command to run the current file.
    vim.api.nvim_chan_send(matlab_term_job, cmd .. "\n")
  end
end, {})

-- Map <space>+r+m (i.e. <leader>rm) to run the MATLAB code
vim.keymap.set("n", "<leader>mr", ":RunMatlab<CR>", { noremap = true, silent = true })

print "MATLAB Keybinds Loaded"
