-- diffview.nvim: full-screen diff and file-history review.
return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory', 'DiffviewClose' },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Diffview Open' },
    { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'File History (Current File)' },
    { '<leader>gH', '<cmd>DiffviewFileHistory<cr>', desc = 'File History' },
  },
  opts = {},
}
