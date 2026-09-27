-- ts-comments.nvim: makes Neovim's built-in `gc` use the right comment syntax
-- for the language under the cursor. Matters in mixed files — a JSX block needs
-- {/* ... */} while the surrounding TS needs //, and native commentstring
-- only knows one per filetype.
return {
  'folke/ts-comments.nvim',
  event = 'VeryLazy',
  opts = {},
}
