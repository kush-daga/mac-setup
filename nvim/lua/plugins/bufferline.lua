-- bufferline.nvim: buffer tabs at the top of the screen.
return {
  'akinsho/bufferline.nvim',
  event = 'VeryLazy',
  dependencies = { 'echasnovski/mini.nvim' },
  keys = {
    { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
    { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
    { '<leader>bd', function() Snacks.bufdelete() end, desc = 'Delete Buffer' },
    { '<leader>bo', '<cmd>BufferLineCloseOthers<cr>', desc = 'Delete Other Buffers' },
    { '<leader>bp', '<cmd>BufferLineTogglePin<cr>', desc = 'Toggle Pin' },
  },
  opts = {
    options = {
      mode = 'buffers',
      diagnostics = 'nvim_lsp',
      offsets = {
        { filetype = 'neo-tree', text = 'Explorer', highlight = 'Directory', text_align = 'left' },
      },
    },
  },
}
