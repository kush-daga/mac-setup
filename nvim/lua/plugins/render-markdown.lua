-- render-markdown.nvim: render markdown (headings, bullets, checkboxes, code, tables) directly in the terminal.
--
-- Three ways to read a markdown file:
--   <leader>mt  toggle the in-buffer render for the current buffer
--   <leader>mp  split pane that shows the fully rendered copy, cursor stays in sync
--   <leader>mg  glow pager in a floating terminal
--   <leader>mz  zen mode, centred and without the side columns

-- Send the buffer to glow in a floating terminal. Unsaved edits are included,
-- so the view always agrees with the buffer. Neovim removes its temp dir on
-- exit. glow needs a real terminal to add colour, thus the terminal window.
-- The -t flag starts the glow pager: j/k scroll, ? shows help, q closes.
local function glow()
  if vim.fn.executable('glow') == 0 then
    vim.notify('glow is not installed: brew install glow', vim.log.levels.WARN)
    return
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file == '' or vim.bo.modified then
    file = vim.fn.tempname() .. '.md'
    vim.fn.writefile(vim.api.nvim_buf_get_lines(0, 0, -1, false), file)
  end

  local name = vim.fn.expand('%:t')
  Snacks.terminal.open({ 'glow', '-t', file }, {
    interactive = true,
    win = {
      position = 'float',
      width = 0.9,
      height = 0.9,
      border = 'rounded',
      title = name ~= '' and (' ' .. name .. ' ') or ' markdown ',
      title_pos = 'center',
    },
  })
end

-- Zen mode set up to read. The column stays narrow, and the number column,
-- the signs and the dimming all go away.
local function reader()
  Snacks.zen({
    toggles = { dim = false, git_signs = false },
    win = {
      width = 90,
      wo = {
        number = false,
        relativenumber = false,
        signcolumn = 'no',
        statuscolumn = '',
        cursorline = false,
        list = false,
        fillchars = 'eob: ',
      },
    },
  })
end

return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = { 'markdown', 'norg', 'rmd', 'org' },
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },

  -- init runs at startup, so the keymaps also apply to the first file opened.
  init = function()
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('user_markdown_keys', { clear = true }),
      pattern = { 'markdown', 'norg', 'rmd', 'org' },
      callback = function(event)
        local function map(lhs, rhs, desc)
          vim.keymap.set('n', lhs, rhs, { buffer = event.buf, desc = desc })
        end
        map('<leader>mt', '<cmd>RenderMarkdown buf_toggle<CR>', 'Toggle inline render')
        map('<leader>mp', '<cmd>RenderMarkdown preview<CR>', 'Preview pane')
        map('<leader>mg', glow, 'Glow view')
        map('<leader>mz', reader, 'Zen reader')
      end,
    })
  end,

  opts = {
    render_modes = { 'n', 'c', 't' },
    -- Show the raw text only on the cursor line. All other lines stay rendered.
    anti_conceal = { enabled = true, above = 0, below = 0 },
    heading = {
      sign = true,
      icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
      -- The background hugs the heading text instead of filling the window.
      width = 'block',
      right_pad = 2,
    },
    -- Indent is off on purpose. It shifts the first line of a paragraph with
    -- virtual text, but wrapped lines cannot follow, so the block loses its
    -- left edge. breakindent in config/autocmds.lua handles the indent.
    indent = { enabled = false },
    bullet = { enabled = true },
    checkbox = {
      enabled = true,
      unchecked = { icon = '󰄱 ' },
      checked = { icon = '󰱒 ' },
    },
    code = {
      enabled = true,
      sign = false,
      -- A code block keeps one straight background column.
      width = 'full',
      border = 'thick',
      language_border = ' ',
    },
    -- The key is pipe_table. A plain `table` key fails the health check.
    pipe_table = { preset = 'round' },
    -- repeat_linebreak would put the bar on wrapped lines too, but it then
    -- writes over the first letter of the text. Keep it off.
    quote = { icon = '▍' },
    link = { enabled = true },
    latex = { enabled = false },
  },
}
