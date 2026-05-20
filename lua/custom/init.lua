vim.keymap.set("i", "jj", "<ESC>")
vim.opt.updatetime = 1000 -- 1 second delay for CursorHold events
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

print "Custom init settings loaded."
