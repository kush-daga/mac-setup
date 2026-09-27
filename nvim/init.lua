-- Bootstrap lazy.nvim and load config modules.

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require('config.options')
require('config.autocmds')
require('config.keymaps')

require('lazy').setup({
  spec = {
    { import = 'plugins' },
  },
  defaults = { lazy = true },
  install = { colorscheme = { 'tokyonight' } },
  checker = { enabled = false },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        'netrwPlugin',
        'tarPlugin',
        'zipPlugin',
        'tohtml',
        'tutor',
      },
    },
  },
})

require('config.theme').setup()
