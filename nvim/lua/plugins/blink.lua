-- blink.cmp: completion engine (lsp, path, snippets, buffer sources).
return {
  'saghen/blink.cmp',
  event = 'InsertEnter',
  version = '*',
  dependencies = { 'rafamadriz/friendly-snippets' },
  opts = {
    keymap = { preset = 'default' },
    appearance = {
      nerd_font_variant = 'mono',
    },
    completion = {
      documentation = { auto_show = true },
      menu = { border = 'rounded' },
    },
    signature = { enabled = true, window = { border = 'rounded' } },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
  },
  opts_extend = { 'sources.default' },
}
