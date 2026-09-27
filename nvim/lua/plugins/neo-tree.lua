-- Neo-tree: sidebar file tree explorer.
return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'echasnovski/mini.nvim',
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '<leader>e', '<cmd>Neotree toggle<cr>', desc = 'Explorer (Neo-tree)' },
  },
  opts = {
    filesystem = {
      follow_current_file = { enabled = true },
      hijack_netrw_behavior = 'disabled',
    },
    window = {
      width = 32,
    },
  },
}
