local function open_float_terminal_with_command(cmd)
  -- 1. Create a scratch buffer (not listed, no file)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  -- 2. Get the dimensions of the current window (the active split)
  local cur_width = vim.api.nvim_win_get_width(0)
  local cur_height = vim.api.nvim_win_get_height(0)

  -- 3. Calculate floating window dimensions relative to the current window.
  --    Here we're using 80% of the current window's width/height.
  local width = math.floor(cur_width * 0.8)
  local height = math.floor(cur_height * 0.8)
  local row = math.floor((cur_height - height) / 2)
  local col = math.floor((cur_width - width) / 2)

  -- 4. Open the floating window relative to the current window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "win", -- Relative to the current window instead of the editor
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  -- 5. Launch your default shell in the new buffer.
  vim.fn.termopen(vim.o.shell)

  -- 6. Use chansend to send the desired command followed by Enter.
  vim.fn.chansend(vim.b.terminal_job_id, cmd .. "\n")
end

-- Create the :Cargo command that accepts subcommands.
vim.api.nvim_create_user_command(
  "Cargo",
  function(opts)
    local args = vim.split(opts.args, "%s+")
    local subcommand = args[1]

    if subcommand == "run" then
      open_float_terminal_with_command "cargo run"
    elseif subcommand == "build" then
      open_float_terminal_with_command "cargo build"
    elseif subcommand == "new" then
      table.remove(args, 1) -- Remove the "new" literal.
      local new_args = table.concat(args, " ")
      if new_args == "" then
        print "Usage: :Cargo new <name> [options]"
        return
      end
      open_float_terminal_with_command("cargo new " .. new_args)
    else
      print "Valid subcommands: run, build, new"
    end
  end,
  { nargs = "*" } -- Allow multiple arguments (e.g. for 'new').
)

-- Key mappings to trigger our Cargo commands in a floating terminal.
vim.keymap.set("n", "<leader>cr", ":Cargo run<CR>", { desc = "Cargo: run in floating terminal" })
vim.keymap.set("n", "<leader>cb", ":Cargo build<CR>", { desc = "Cargo: build in floating terminal" })
vim.keymap.set("n", "<leader>cn", ":Cargo new ", { desc = "Cargo: new in floating terminal" })

print "Rust Keybinds Loaded"
