-- todo-comments.nvim: highlight and list TODO/FIXME/HACK/NOTE/WARN comments.
return {
  'folke/todo-comments.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {},
  keys = {
    { '<leader>ft', '<cmd>TodoTrouble<cr>', desc = 'Todo (Trouble)' },
  },
}
