return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
        callback = function(event)
          local telescope = require 'telescope.builtin'
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grr', telescope.lsp_references, '[G]oto [R]eferences')
          map('gri', telescope.lsp_implementations, '[G]oto [I]mplementations')
          map('grd', telescope.lsp_definitions, '[G]oto [D]efinitions')
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gO', telescope.lsp_document_symbols, 'Open Document Symbols')
          map('gW', telescope.lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
          map('grt', telescope.lsp_type_definitions, '[G]oto [T]ype Definition')
          map('<C-h>', vim.lsp.buf.signature_help, 'Show signature help', 'i')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle inlay [H]ints')
          end
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('blink-cmp').get_lsp_capabilities(capabilities)

      vim.lsp.config('*', {
        capabilities = capabilities,
      })

      vim.lsp.config('nil_ls', {
        settings = {
          ['nil'] = {
            formatting = { command = { 'alejandra' } },
          },
        },
      })

      vim.lsp.config('bashls', {
        filetypes = { 'sh', 'bash', 'zsh' },
      })

      vim.lsp.config('qmlls', {
        cmd = { 'qmlls' },
        filetypes = { 'qml' },
        single_file_support = true,
      })

      vim.lsp.config('emmet_ls', {
        filetypes = { 'html', 'css', 'scss', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
      })

      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            completion = { callSnippet = 'Replace' },
          },
        },
      })

      vim.lsp.enable {
        'bashls',
        'qmlls',
        'nil_ls',
        'emmet_ls',
        'lua_ls',
      }

      vim.diagnostic.config {
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = true,
        underline = { severity = vim.diagnostic.severity.ERROR },
        update_in_insert = false,
        float = {
          focusable = false,
          style = 'minimal',
          border = 'rounded',
          source = true,
        },
      }

      vim.keymap.set('n', '<leader>dq', vim.diagnostic.setqflist, { desc = 'Workspace [d]iagnostics (Quickfix)' })
      vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, { desc = 'Buffer diagnostics (Location List)' })
      vim.keymap.set('n', 'df', vim.diagnostic.open_float, { desc = 'Show line diagnostics' })

      vim.keymap.set('n', '<leader>lx', function()
        local current = vim.diagnostic.config().virtual_text
        vim.diagnostic.config { virtual_text = not current }
      end, { desc = 'Toggle LSP virtual text' })
    end,
  },
}
