-- Colorscheme plugins, all installed eagerly so lua/config/theme.lua can switch instantly.
--
-- Each one is told to skip painting a window background, so Ghostty's
-- translucent background shows through instead of being covered by an opaque
-- `Normal` highlight. Themes without such an option are handled by the
-- fallback in lua/config/theme.lua.
return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      styles = { sidebars = 'transparent', floats = 'transparent' },
    },
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    opts = { transparent_background = true },
  },
  {
    'rebelot/kanagawa.nvim',
    lazy = false,
    priority = 1000,
    opts = { transparent = true },
  },
  {
    'marko-cerovac/material.nvim',
    lazy = false,
    priority = 1000,
    opts = { disable = { background = true } },
  },
  {
    -- nord.nvim is configured through globals, not a setup table.
    'shaunsingh/nord.nvim',
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.nord_disable_background = true
      vim.g.nord_italic = true
    end,
  },
  {
    -- oceanic-next has no transparency option; theme.lua's fallback covers it.
    'mhartington/oceanic-next',
    lazy = false,
    priority = 1000,
  },
}
