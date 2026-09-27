-- General keymaps not tied to a specific plugin. Leader/localleader are set in init.lua.

local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Window navigation
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move to left window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move to lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move to upper window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move to right window' })

-- Window resizing
map('n', '<C-Up>', '<cmd>resize +2<CR>', { desc = 'Increase window height' })
map('n', '<C-Down>', '<cmd>resize -2<CR>', { desc = 'Decrease window height' })
map('n', '<C-Left>', '<cmd>vertical resize -2<CR>', { desc = 'Decrease window width' })
map('n', '<C-Right>', '<cmd>vertical resize +2<CR>', { desc = 'Increase window width' })

map('n', '<leader>w', '<cmd>write<CR>', { desc = 'Write buffer' })
map('n', '<leader>q', '<cmd>quit<CR>', { desc = 'Quit window' })

-- Move selected lines up/down in visual mode
map('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
map('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Keep selection when indenting
map('v', '<', '<gv', { desc = 'Indent left' })
map('v', '>', '>gv', { desc = 'Indent right' })

-- Keep cursor centred when jumping between search results
map('n', 'n', 'nzzzv', { desc = 'Next search result (centered)' })
map('n', 'N', 'Nzzzv', { desc = 'Prev search result (centered)' })

-- Keep cursor position when joining lines
map('n', 'J', 'mzJ`z', { desc = 'Join lines (keep cursor position)' })

map({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Yank to system clipboard' })
map('n', '<leader>Y', '"+Y', { desc = 'Yank line to system clipboard' })
map('v', '<leader>p', '"_dP', { desc = 'Paste over selection without yanking' })

map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

map('n', '<leader>-', '<cmd>split<CR>', { desc = 'Split window below' })
map('n', '<leader>|', '<cmd>vsplit<CR>', { desc = 'Split window right' })

-- Diagnostics
map('n', ']d', function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = 'Next diagnostic' })
map('n', '[d', function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = 'Prev diagnostic' })
map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line diagnostics' })

map('n', '<leader>ur', '<cmd>nohlsearch<CR><C-l>', { desc = 'Redraw screen' })
map('n', '<leader>us', '<cmd>setlocal spell!<CR>', { desc = 'Toggle spellcheck' })
