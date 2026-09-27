-- grug-far.nvim: project-wide find and replace, in a buffer you can edit.
-- Fills the one real gap in this config — `rgi` and fzf-lua find things,
-- but neither could rewrite them across a repo.
return {
  'MagicDuck/grug-far.nvim',
  cmd = 'GrugFar',
  opts = { headerMaxWidth = 80 },
  keys = {
    {
      '<leader>sr',
      function()
        require('grug-far').open({ transient = true })
      end,
      desc = 'Search and replace (project)',
    },
    {
      '<leader>sw',
      function()
        require('grug-far').open({ transient = true, prefills = { search = vim.fn.expand('<cword>') } })
      end,
      desc = 'Search and replace word under cursor',
    },
    {
      '<leader>sr',
      mode = 'v',
      function()
        require('grug-far').with_visual_selection({ transient = true })
      end,
      desc = 'Search and replace selection',
    },
    {
      '<leader>sf',
      function()
        require('grug-far').open({
          transient = true,
          prefills = { paths = vim.fn.expand('%') },
        })
      end,
      desc = 'Search and replace in this file',
    },
  },
}
