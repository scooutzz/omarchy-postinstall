return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    lazy = false,
    init = function()
      -- 1. Seus parsers customizados
      local parsers = {
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'typescript',
        'javascript',
        'css',
        'scss',
        'json',
        'vue',
        'gitignore',
        'gitcommit',
      }

      -- Grupo customizado para a sua config
      local group = vim.api.nvim_create_augroup('RelaxouTreesitter', { clear = true })

      vim.api.nvim_create_autocmd({ 'BufEnter', 'FileType' }, {
        group = group,
        callback = function()
          if vim.bo.buftype ~= '' then
            return
          end
          pcall(vim.treesitter.start, 0)
        end,
      })

      vim.api.nvim_create_autocmd('User', {
        group = group,
        pattern = 'VeryLazy',
        once = true,
        callback = function()
          -- Instala os parsers declarados acima
          require('nvim-treesitter').install(parsers)

          -- Garante que o seu highlight e indent originais funcionem em segurança
          pcall(function()
            require('nvim-treesitter.configs').setup {
              highlight = {
                enable = true,
                additional_vim_regex_highlighting = { 'ruby' },
              },
              indent = { enable = true, disable = { 'ruby', 'typescript', 'vue' } },
            }
          end)
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    lazy = false,
    config = function()
      -- O textobjects usa o configs.setup por baixo dos panos.
      -- O pcall aqui garante que ele não vai quebrar a tela se carregar antes da hora.
      pcall(function()
        require('nvim-treesitter.configs').setup {
          textobjects = {
            select = {
              enable = true,
              lookahead = true,
              keymaps = {
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
              },
            },
          },
        }
      end)
    end,
  },
}
