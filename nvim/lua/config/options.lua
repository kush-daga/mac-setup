-- Core editor options.

local o = vim.o

o.number = true
o.relativenumber = true
o.mouse = 'a'
o.showmode = false

-- Sync clipboard after UIEnter to avoid startup cost when unnamedplus isn't needed yet.
vim.schedule(function()
  o.clipboard = 'unnamedplus'
end)

o.breakindent = true
o.undofile = true
o.ignorecase = true
o.smartcase = true
o.signcolumn = 'yes'
o.updatetime = 250
o.timeoutlen = 300
o.splitright = true
o.splitbelow = true

o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

o.inccommand = 'split'
o.cursorline = true
o.scrolloff = 10
o.confirm = true
o.termguicolors = true

o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true
o.wrap = false

o.laststatus = 3
o.winborder = 'rounded'

vim.opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' }

o.completeopt = 'menu,menuone,noselect'
o.pumheight = 12
o.history = 1000
o.autoread = true
