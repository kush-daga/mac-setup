-- Autocommands.

local function augroup(name)
  return vim.api.nvim_create_augroup('user_' .. name, { clear = true })
end

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup('highlight_yank'),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Pick up changes made to files outside of nvim
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold' }, {
  group = augroup('checktime'),
  command = 'checktime',
})

-- Restore last cursor position on file open
vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup('last_loc'),
  callback = function(event)
    local exclude = { 'gitcommit' }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc then
      return
    end
    vim.b[buf].last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-create missing parent directories on save
vim.api.nvim_create_autocmd('BufWritePre', {
  group = augroup('auto_mkdir'),
  callback = function(event)
    if event.match:match('^%w%w+://') then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- Close scratch/help/qf/man filetypes with q
vim.api.nvim_create_autocmd('FileType', {
  group = augroup('close_with_q'),
  pattern = { 'help', 'qf', 'man', 'lspinfo', 'checkhealth', 'notify' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = event.buf, silent = true })
  end,
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = augroup('close_scratch_with_q'),
  callback = function(event)
    local bt = vim.bo[event.buf].buftype
    if bt == 'nofile' or bt == 'scratch' then
      vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = event.buf, silent = true })
    end
  end,
})

-- Resize splits evenly when the window is resized
vim.api.nvim_create_autocmd('VimResized', {
  group = augroup('resize_splits'),
  callback = function()
    vim.cmd('tabdo wincmd =')
  end,
})

-- Prose filetypes: wrap the text the way a document does.
--   linebreak       wrap at a space, never inside a word
--   breakindentopt  keep wrapped lines under the text of a list item
--   formatlistpat   tell Neovim which lines start a list item
-- Spellcheck stays off in markdown. Technical docs hold many identifiers and
-- each one becomes a false error. Press <leader>us to switch it on.
vim.api.nvim_create_autocmd('FileType', {
  group = augroup('prose'),
  pattern = { 'markdown', 'gitcommit', 'text' },
  callback = function(event)
    vim.wo.wrap = true
    vim.wo.linebreak = true
    vim.wo.breakindent = true
    vim.wo.breakindentopt = 'list:-1'
    vim.bo[event.buf].formatlistpat = [[^\s*\%(\d\+[.)]\|[-*+]\)\s\+]]
    vim.wo.spell = event.match ~= 'markdown'
    -- Indent guides add noise to a document.
    vim.b[event.buf].snacks_indent = false
  end,
})
