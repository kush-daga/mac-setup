-- gitsigns.nvim: git change signs, hunk navigation/actions, and blame.
return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    signs = {
      add = { text = '│' },
      change = { text = '│' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
      untracked = { text = '┆' },
    },
    current_line_blame = false,
    on_attach = function(bufnr)
      local gs = require('gitsigns')
      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      map('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal({ ']c', bang = true })
        else
          gs.nav_hunk('next')
        end
      end, 'Next Hunk')

      map('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal({ '[c', bang = true })
        else
          gs.nav_hunk('prev')
        end
      end, 'Prev Hunk')

      map('n', '<leader>hs', gs.stage_hunk, 'Stage Hunk')
      map('n', '<leader>hr', gs.reset_hunk, 'Reset Hunk')
      map('n', '<leader>hp', gs.preview_hunk, 'Preview Hunk')
      map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, 'Blame Line')
      map('n', '<leader>hd', gs.diffthis, 'Diff This')
      map('n', '<leader>tb', gs.toggle_current_line_blame, 'Toggle Current Line Blame')
    end,
  },
}
