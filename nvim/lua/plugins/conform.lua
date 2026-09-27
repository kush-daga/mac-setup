-- conform.nvim: format on save, with a manual format keymap and a toggle.
return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo', 'FormatToggle' },
  init = function()
    vim.g.disable_autoformat = false
  end,
  keys = {
    { '<leader>cf', function() require('conform').format({ async = true, lsp_format = 'fallback' }) end, desc = 'Format Buffer' },
    { '<leader>uf', '<cmd>FormatToggle<cr>', desc = 'Toggle Format on Save' },
  },
  opts = {
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'ruff_format', 'ruff_organize_imports' },
      javascript = { 'prettierd' },
      javascriptreact = { 'prettierd' },
      typescript = { 'prettierd' },
      typescriptreact = { 'prettierd' },
      json = { 'prettierd' },
      jsonc = { 'prettierd' },
      yaml = { 'prettierd' },
      css = { 'prettierd' },
      html = { 'prettierd' },
      markdown = { 'prettierd' },
      go = { 'gofumpt', 'goimports' },
      sh = { 'shfmt' },
    },
    format_on_save = function()
      if vim.g.disable_autoformat then
        return
      end
      return { timeout_ms = 1000, lsp_format = 'fallback' }
    end,
  },
  config = function(_, opts)
    require('conform').setup(opts)

    vim.api.nvim_create_user_command('FormatToggle', function()
      vim.g.disable_autoformat = not vim.g.disable_autoformat
      vim.notify('Format on save ' .. (vim.g.disable_autoformat and 'disabled' or 'enabled'))
    end, { desc = 'Toggle format on save' })
  end,
}
