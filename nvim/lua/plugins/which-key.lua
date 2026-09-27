-- which-key.nvim: keymap hints and <leader> group labels.
return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    preset = 'helix',
    spec = {
      { '<leader>f', group = 'find' },
      { '<leader>g', group = 'git' },
      { '<leader>h', group = 'hunk' },
      { '<leader>m', group = 'markdown' },
      { '<leader>c', group = 'code' },
      { '<leader>u', group = 'ui/toggle' },
      { '<leader>t', group = 'toggle' },
      { '<leader>b', group = 'buffer' },
      { '<leader>w', group = 'window' },
      { '<leader>s', group = 'search' },
      { '<leader>x', group = 'diagnostics' },
      { '<leader>q', group = 'quit/session' },
    },
  },
}
