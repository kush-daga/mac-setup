-- mini.nvim: surround, autopairs, textobjects, and icons (mocking nvim-web-devicons for other plugins).
return {
  'echasnovski/mini.nvim',
  lazy = false,
  priority = 900,
  config = function()
    require('mini.surround').setup({
      mappings = {
        add = 'gsa',
        delete = 'gsd',
        find = 'gsf',
        find_left = 'gsF',
        highlight = 'gsh',
        replace = 'gsr',
        update_n_lines = 'gsn',
      },
    })
    require('mini.pairs').setup()
    require('mini.ai').setup()
    require('mini.icons').setup()
    require('mini.icons').mock_nvim_web_devicons()
  end,
}
