-- We modify our previously defined Cargo user command:
vim.api.nvim_create_user_command("Cargo", function(opts)
  -- Split the entire command-line input (opts.args) by spaces.
  -- For example, if someone types :Cargo new test_project --bin
  -- the split might be {"new", "test_project", "--bin"}.
  local args = vim.split(opts.args, "%s+")

  -- The first item is the subcommand: "run", "build", or "new".
  local subcommand = args[1]

  if subcommand == "run" then
    vim.cmd "!cargo run"
  elseif subcommand == "build" then
    vim.cmd "!cargo build"
  elseif subcommand == "new" then
    -- Everything after 'new' is the project name plus optional flags.
    -- Let's remove 'new' from the table, then join the rest with spaces.
    table.remove(args, 1) -- remove 'new'
    local new_args = table.concat(args, " ")
    if #new_args == 0 then
      print "Usage: :Cargo new <name> [options]"
      return
    end

    -- Run "cargo new whatever-is-left"
    vim.cmd("!cargo new " .. new_args)
  else
    print(
      "Please provide 'run', 'build', or 'new' as an argument to :Cargo. "
        .. "For 'new', also specify <name> [options]."
    )
  end
end, {
  -- We make nargs = '*' so you can type multiple arguments
  -- e.g. ':Cargo new test_project --bin'
  nargs = "*",
})

-- Keymaps remain the same, or you could add more if you want:
vim.keymap.set("n", "<leader>cr", ":Cargo run<CR>", { desc = "Cargo: run" })
vim.keymap.set("n", "<leader>cb", ":Cargo build<CR>", { desc = "Cargo: build" })
-- Optionally, bind something for "new":
vim.keymap.set("n", "<leader>cn", ":Cargo new ", { desc = "Cargo: new" })
-- Notice we didn't put <CR> at the end of ':Cargo new ' because you typically
-- want to type your project name before pressing Enter.
