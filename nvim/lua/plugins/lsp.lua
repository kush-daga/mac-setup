-- LSP: mason-managed servers configured via the 0.11+ vim.lsp.config/vim.lsp.enable APIs.
return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'saghen/blink.cmp',
    },
    config = function()
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { 'vim' } },
              workspace = {
                library = vim.list_extend(vim.api.nvim_get_runtime_file('', true), { vim.env.VIMRUNTIME }),
                checkThirdParty = false,
              },
            },
          },
        },
        basedpyright = {},
        ruff = {},
        ts_ls = {},
        gopls = {
          settings = {
            gopls = { gofumpt = true },
          },
        },
        jsonls = {},
        yamlls = {},
        bashls = {},
        dockerls = {},
        taplo = {},
      }

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      for name, opts in pairs(servers) do
        opts.capabilities = vim.tbl_deep_extend('force', {}, capabilities, opts.capabilities or {})
        vim.lsp.config(name, opts)
      end

      require('mason-lspconfig').setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_enable = true,
      })

      require('mason-tool-installer').setup({
        ensure_installed = { 'stylua', 'prettierd', 'gofumpt', 'goimports', 'shfmt' },
      })

      vim.diagnostic.config({
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.INFO] = '',
            [vim.diagnostic.severity.HINT] = '',
          },
        },
        virtual_text = {
          source = 'if_many',
          spacing = 2,
        },
        float = { border = 'rounded' },
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('user_lsp_attach', { clear = true }),
        callback = function(event)
          local function map(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('grn', vim.lsp.buf.rename, 'Rename')
          map('gra', vim.lsp.buf.code_action, 'Code Action')
          map('grr', function() require('fzf-lua').lsp_references() end, 'References')
          map('gri', vim.lsp.buf.implementation, 'Implementation')
          map('grd', function() require('fzf-lua').lsp_definitions() end, 'Definition')
          map('grD', vim.lsp.buf.declaration, 'Declaration')
          map('grt', vim.lsp.buf.type_definition, 'Type Definition')
          map('gO', vim.lsp.buf.document_symbol, 'Document Symbols')
          map('K', vim.lsp.buf.hover, 'Hover')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method('textDocument/inlayHint') then
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
            map('<leader>th', function()
              local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
              vim.lsp.inlay_hint.enable(not enabled, { bufnr = event.buf })
            end, 'Toggle Inlay Hints')
          end
        end,
      })
    end,
  },
}
