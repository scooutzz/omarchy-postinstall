require("config.remote_clipboard").steup()

vim.g.have_nerd_font = true

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
-- vim.opt.signcolumn = 'yes'
-- vim.opt.colorcolumn = '100'
vim.opt.cursorline = true
vim.opt.guicursor = ''
vim.opt.showcmdloc = 'statusline'
vim.opt.showmode = false
vim.opt.laststatus = 3

vim.opt.scrolloff = 8
vim.opt.mouse = 'a'
vim.opt.wrap = false
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.breakindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = 'split'

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.isfname:append '@-@'

vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo.foldlevel = 99

vim.opt.confirm = true

vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)
