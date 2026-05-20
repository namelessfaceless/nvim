vim.g.dap_virtual_text = false
vim.env.PATH = vim.env.PATH .. ":/Users/danesabo/.ghcup/bin"
vim.keymap.set("i", "jj", "<ESC>")
vim.opt.updatetime = 1000 -- 1 second delay for CursorHold events
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

require "custom.language_specific_commands.cadquery"
require "custom.git_quickpush"
print "Custom init settings loaded."
