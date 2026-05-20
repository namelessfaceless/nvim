-- ------------------------------------------------------------------------
-- MATLAB runner: vertical split, CLI-only with no display, reusable buffer
-- ------------------------------------------------------------------------
local matlab_term_buf = nil
local matlab_term_job = nil

vim.api.nvim_create_user_command("RunMatlab", function()
  -- full path to current .m file, escape single quotes
  local file = vim.fn.expand "%:p"
  local matlab_file = file:gsub("'", "''")

  -- build your CLI command: no desktop panels, no splash,
  -- run the script, and stay in the prompt
  local cmd = table.concat({
    "matlab",
    "-nodisplay",
    "-nodesktop",
    "-nosplash",
    "-r",
    string.format(
      "'try, run(''%s''), catch, disp(getReport(lasterror)), end, disp(\"<< done >>\"), pause'",
      matlab_file
    ),
  }, " ")

  if matlab_term_buf and vim.api.nvim_buf_is_valid(matlab_term_buf) and matlab_term_job then
    -- if buffer exists, show or jump to it
    local wins = vim.fn.win_findbuf(matlab_term_buf)
    if #wins == 0 then
      vim.cmd "vsplit"
      vim.cmd("buffer " .. matlab_term_buf)
    else
      vim.api.nvim_set_current_win(wins[1])
    end
    vim.api.nvim_chan_send(matlab_term_job, cmd .. "\n")
  else
    -- new vertical split + terminal
    vim.cmd "vsplit"
    vim.cmd "terminal"
    matlab_term_buf = vim.api.nvim_get_current_buf()
    matlab_term_job = vim.b.terminal_job_id
    vim.api.nvim_buf_set_name(matlab_term_buf, "MATLAB-CLI")
    vim.api.nvim_chan_send(matlab_term_job, cmd .. "\n")
  end
end, {})

vim.keymap.set("n", "<leader>mr", ":RunMatlab<CR>", { noremap = true, silent = true })

-- ------------------------------------------------------------------------
-- Live‑Script style commenting: prepend "%[" on each line in a range
-- ------------------------------------------------------------------------
vim.api.nvim_create_user_command("CommentLive", function(opts)
  local start_line, end_line = opts.line1, opts.line2
  -- the replacement inserts literal "%[" at start of each line
  vim.cmd(string.format("%d,%d s/^/%%[/", start_line, end_line))
end, {
  range = true,
  desc = "Prepend '%[' to each line (MATLAB Live Script style)",
})

-- map <leader>mc in visual mode to comment (only works with selection)
vim.keymap.set("v", "<leader>mc", ":CommentLive<CR>", { noremap = true, silent = true })

print "MATLAB Keybinds & Live‑Script Commenter Loaded"
