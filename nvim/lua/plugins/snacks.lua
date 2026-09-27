-- Snacks: dashboard, notifier, lazygit/terminal integration, indent guides, and other QoL utilities.
return {
  'folke/snacks.nvim',
  lazy = false,
  priority = 1000,
  opts = {
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    notifier = { enabled = true },
    indent = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    input = { enabled = true },
    scroll = { enabled = false },
    lazygit = { enabled = true },
    terminal = { enabled = true },
    gitbrowse = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        header = table.concat({
          '███╗   ██╗██╗   ██╗██╗███╗   ██╗',
          '████╗  ██║██║   ██║██║████╗  ██║',
          '██╔██╗ ██║██║   ██║██║██╔██╗ ██║',
          '██║╚██╗██║╚██╗ ██╔╝██║██║╚██╗██║',
          '██║ ╚████║ ╚████╔╝ ██║██║ ╚████║',
          '╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝  ╚═══╝',
        }, '\n'),
      },
      sections = {
        { section = 'header' },
        { section = 'keys', gap = 1, padding = 1 },
        { section = 'recent_files', limit = 8, padding = 1 },
        { section = 'projects', limit = 6, padding = 1 },
        { section = 'startup' },
      },
    },
  },
  keys = {
    { '<leader>gg', function() Snacks.lazygit() end, desc = 'Lazygit' },
    { '<leader>gB', function() Snacks.gitbrowse() end, desc = 'Git Browse' },
    { '<C-/>', function() Snacks.terminal() end, desc = 'Toggle Terminal', mode = { 'n', 't' } },
  },
}
