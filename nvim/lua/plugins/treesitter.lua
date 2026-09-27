-- Treesitter: syntax highlighting, indentation, and structural text objects.
--
-- Pinned to the "main" branch on purpose. The old `master` branch (ensure_installed /
-- highlight.enable / indent.enable) is archived AND broken on Neovim 0.12: opening a
-- markdown buffer throws "attempt to call method 'range' (a nil value)" from its legacy
-- query-predicate code. `main` has a different API, used below.
--
-- `main` compiles grammars by shelling out to the standalone `tree-sitter` CLI, so that
-- binary is a hard requirement, not an extra. It comes from `brew install tree-sitter-cli`
-- (it is in the Brewfile). Do NOT use `npm i -g tree-sitter-cli`: npm installs it into the
-- *active nvm node version's* bin dir, so it silently disappears on a node switch and then
-- no parsers install at all. `dotfiles-doctor` checks which one is on PATH.
local ensure_installed = {
  'lua', 'vim', 'vimdoc', 'python', 'typescript', 'tsx', 'javascript',
  'go', 'gomod', 'rust', 'bash', 'json', 'yaml', 'toml',
  'markdown', 'markdown_inline', 'sql', 'dockerfile', 'gitcommit',
  'diff', 'html', 'css', 'regex', 'ruby',
}

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,
    config = function()
      -- jsonc has no parser of its own; it reuses the json grammar.
      vim.treesitter.language.register('json', 'jsonc')

      require('nvim-treesitter').install(ensure_installed)

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('user_treesitter_start', { clear = true }),
        callback = function(event)
          local lang = vim.treesitter.language.get_lang(event.match) or event.match
          if not vim.treesitter.language.add(lang) then
            return
          end
          vim.treesitter.start(event.buf, lang)
          vim.bo[event.buf].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter-textobjects').setup({
        select = { lookahead = true },
      })

      local select = require('nvim-treesitter-textobjects.select')
      local function map(lhs, query)
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          select.select_textobject(query, 'textobjects')
        end)
      end

      map('af', '@function.outer')
      map('if', '@function.inner')
      map('ac', '@class.outer')
      map('ic', '@class.inner')
      map('aa', '@parameter.outer')
      map('ia', '@parameter.inner')
    end,
  },
}
