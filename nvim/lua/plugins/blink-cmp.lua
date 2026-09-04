return {
  'saghen/blink.cmp',
  event = 'VimEnter',
  version = '1.*',
  dependencies = {
    'L3MON4D3/LuaSnip',
    'folke/lazydev.nvim',
  },
  opts = {
    keymap = {
      preset = 'default',
    },
    appearance = {
      use_nvim_cmp_as_default = false,
      nerd_font_variant = 'mono',
    },
    completion = {
      menu = { auto_show = true },
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
      ghost_text = {
        enabled = false,
        show_with_menu = false,
      },
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
    },
    cmdline = {
      enabled = true,
      keymap = { preset = 'cmdline' },
      completion = {
        menu = { auto_show = true },
      },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'lazydev' },
      providers = {
        lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
      },
    },
    snippets = { preset = 'luasnip' },
    fuzzy = { implementation = 'lua' },
    signature = { enabled = true },
  },
}
