-- fzf-lua: primary fuzzy finder for files, grep, buffers, LSP, and git.
return {
  'ibhagwan/fzf-lua',
  cmd = 'FzfLua',
  dependencies = { 'echasnovski/mini.nvim' },
  opts = {
    'telescope',
    winopts = {
      height = 0.85,
      width = 0.85,
      border = 'rounded',
    },
    -- A picker's input line owns every keystroke, so `j`/`k` type into the
    -- query rather than moving the cursor. These give list movement without
    -- leaving the home row. ctrl-q is the escape hatch: it dumps every result
    -- into the quickfix list, where real vim motions work.
    keymap = {
      fzf = {
        ['ctrl-j'] = 'down',
        ['ctrl-k'] = 'up',
        ['ctrl-q'] = 'select-all+accept',
        ['alt-j'] = 'preview-down',
        ['alt-k'] = 'preview-up',
      },
    },
  },
  keys = {
    { '<leader><space>', function() require('fzf-lua').files() end, desc = 'Find Files' },
    { '<leader>ff', function() require('fzf-lua').files() end, desc = 'Find Files' },
    { '<leader>fg', function() require('fzf-lua').live_grep() end, desc = 'Live Grep' },
    { '<leader>fw', function() require('fzf-lua').grep_cword() end, desc = 'Grep Word Under Cursor' },
    { '<leader>fb', function() require('fzf-lua').buffers() end, desc = 'Buffers' },
    { '<leader>fh', function() require('fzf-lua').helptags() end, desc = 'Help Tags' },
    { '<leader>fk', function() require('fzf-lua').keymaps() end, desc = 'Keymaps' },
    { '<leader>fr', function() require('fzf-lua').oldfiles() end, desc = 'Recent Files' },
    { '<leader>fd', function() require('fzf-lua').diagnostics_document() end, desc = 'Diagnostics' },
    { '<leader>fs', function() require('fzf-lua').lsp_document_symbols() end, desc = 'Document Symbols' },
    { '<leader>fS', function() require('fzf-lua').lsp_live_workspace_symbols() end, desc = 'Workspace Symbols' },
    { '<leader>f/', function() require('fzf-lua').lgrep_curbuf() end, desc = 'Lines in Buffer' },
    { '<leader>fc', function() require('fzf-lua').git_commits() end, desc = 'Git Commits' },
    { '<leader>fB', function() require('fzf-lua').git_branches() end, desc = 'Git Branches' },
  },
}
