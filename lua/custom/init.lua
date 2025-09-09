vim.g.dap_virtual_text = false
vim.g.tlaplus_mappings_enable = true
vim.env.PATH = vim.env.PATH .. ":/home/danesabo/.ghcup/bin"
vim.g.loaded_python3_provider = 1
vim.g.python3_host_prog = vim.fn.expand "~/.config/nvim/nvim_venv/bin/python"
vim.keymap.set("i", "jj", "<ESC>")

require "custom.zk"
require "custom.git_quickpush"
require "custom.journal"
require "custom.taskwarrior"
print "Custom init settings loaded."
