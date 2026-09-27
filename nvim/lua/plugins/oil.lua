-- Oil: edit the filesystem like a normal buffer. Loaded eagerly so it can claim directory args at startup.
return {
  'stevearc/oil.nvim',
  lazy = false,
  dependencies = { 'echasnovski/mini.nvim' },
  keys = {
    { '-', function() require('oil').open() end, desc = 'Open parent directory (Oil)' },
  },
  opts = {
    default_file_explorer = true,
    view_options = {
      show_hidden = true,
    },
  },
}
