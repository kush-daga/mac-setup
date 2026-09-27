-- Single source of truth for the colorscheme: reads ~/.config/theme (shared with the rest of
-- the dotfiles) and applies the matching nvim colorscheme. Exposes :ThemeReload.

local M = {}

local theme_file = vim.fn.expand('~/.config/theme')
local DEFAULT_NAME = 'tokyonight-storm'

-- `theme` writes the resolved colorscheme to ~/.config/theme-nvim, so this
-- table is only a fallback for when that file is missing. Adding a theme
-- means writing themes/<name>.sh in the dotfiles repo and nothing here.
local THEME_MAP = {
  ['tokyonight-storm'] = 'tokyonight-storm',
  ['oceanic-next'] = 'oceanicnext',
  ['nord'] = 'nord',
  ['kanagawa-wave'] = 'kanagawa-wave',
  ['material-ocean'] = 'material',
  ['material-ocean-bright'] = 'material',
  ['catppuccin-macchiato'] = 'catppuccin-macchiato',
}

-- Themes that need a plugin variable set before the colorscheme loads.
local THEME_VARS = {
  ['material-ocean'] = function() vim.g.material_style = 'deep ocean' end,
  ['material-ocean-bright'] = function() vim.g.material_style = 'deep ocean' end,
}

local nvim_file = vim.fn.expand('~/.config/theme-nvim')

--- Colorscheme written by the `theme` command, if it left one.
local function colorscheme_from_file()
  local ok, lines = pcall(vim.fn.readfile, nvim_file)
  if not ok or not lines or #lines == 0 then
    return nil
  end
  local name = vim.trim(lines[1])
  return name ~= '' and name or nil
end

--- Read the theme name from ~/.config/theme, falling back to the default on any problem.
function M.read_name()
  local ok, lines = pcall(vim.fn.readfile, theme_file)
  if not ok or not lines or #lines == 0 then
    return DEFAULT_NAME
  end
  local name = vim.trim(lines[1])
  -- Accept any name: the colorscheme may come from ~/.config/theme-nvim,
  -- so an unknown name here is not an error.
  return name ~= '' and name or DEFAULT_NAME
end

--- Resolve a theme name to an nvim colorscheme.
--- Order: what `theme` wrote, then the fallback map, then the default.
function M.resolve(name)
  return colorscheme_from_file() or THEME_MAP[name] or THEME_MAP[DEFAULT_NAME]
end

--- Apply the colorscheme for the current ~/.config/theme. Returns the resolved colorscheme name.
function M.apply()
  local name = M.read_name()
  local colorscheme = M.resolve(name)

  local set_vars = THEME_VARS[name]
  if set_vars then
    set_vars()
  end

  local ok, err = pcall(vim.cmd.colorscheme, colorscheme)
  if not ok then
    vim.notify("theme: failed to load colorscheme '" .. colorscheme .. "': " .. err, vim.log.levels.WARN)
    pcall(vim.cmd.colorscheme, DEFAULT_NAME)
    return DEFAULT_NAME
  end

  return colorscheme
end

-- ── Transparency ─────────────────────────────────────────────────────────
-- Ghostty runs at background-opacity 0.88. A colorscheme's opaque `Normal`
-- background would paint straight over that, so the terminal looks solid
-- the moment nvim starts. Most themes have a transparency option (set in
-- plugins/colorschemes.lua); this clears what they miss, plus the plugin
-- surfaces that hardcode their own background.
--
-- Interactive surfaces are deliberately left opaque — a see-through
-- completion menu or visual selection sitting on top of text is unreadable.
local TRANSPARENT_GROUPS = {
  -- editor
  'Normal', 'NormalNC', 'NormalFloat', 'FloatBorder', 'FloatTitle',
  'SignColumn', 'LineNr', 'CursorLineNr', 'EndOfBuffer', 'NonText',
  'MsgArea', 'MsgSeparator', 'VertSplit', 'WinSeparator', 'Folded',
  'StatusLine', 'StatusLineNC', 'TabLine', 'TabLineFill', 'TabLineSel',
  -- plugin windows
  'NeoTreeNormal', 'NeoTreeNormalNC', 'NeoTreeEndOfBuffer',
  'NeoTreeWinSeparator', 'NeoTreeFloatBorder', 'NeoTreeFloatNormal',
  'TroubleNormal', 'TroubleNormalNC',
  'FzfLuaNormal', 'FzfLuaBorder', 'FzfLuaPreviewNormal', 'FzfLuaPreviewBorder',
  'WhichKeyFloat', 'WhichKeyBorder',
  'LazyNormal', 'MasonNormal',
  'SnacksNormal', 'SnacksNormalNC', 'SnacksDashboardNormal',
  'SnacksIndent', 'SnacksNotifierInfo',
  'BufferLineFill', 'BufferLineBackground',
  'DiffviewNormal', 'OilNormal',
}

--- Strip the background from every group above, keeping their foregrounds.
local function clear_backgrounds()
  for _, group in ipairs(TRANSPARENT_GROUPS) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if ok and hl then
      hl.bg = nil
      hl.ctermbg = nil
      pcall(vim.api.nvim_set_hl, 0, group, hl)
    end
  end
end

--- Is transparency on? Persisted in ~/.config/theme-opaque (presence = opaque).
local opaque_flag = vim.fn.expand('~/.config/theme-opaque')

function M.is_transparent()
  return vim.uv.fs_stat(opaque_flag) == nil
end

function M.apply_transparency()
  if M.is_transparent() then
    clear_backgrounds()
  end
end

function M.setup()
  M.apply()

  -- Re-clear after any future colorscheme change, including ones a plugin
  -- triggers, so transparency is never silently lost.
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('user_theme_transparency', { clear = true }),
    callback = function()
      vim.schedule(M.apply_transparency)
    end,
  })
  M.apply_transparency()

  vim.api.nvim_create_user_command('TransparencyToggle', function()
    if M.is_transparent() then
      local fd = io.open(opaque_flag, 'w')
      if fd then
        fd:write('opaque\n')
        fd:close()
      end
      M.apply()
      vim.notify('Background: opaque (theme colours)')
    else
      os.remove(opaque_flag)
      M.apply()
      M.apply_transparency()
      vim.notify('Background: transparent (terminal shows through)')
    end
  end, { desc = 'Toggle whether the terminal background shows through' })

  vim.api.nvim_create_user_command('ThemeReload', function()
    local colorscheme = M.apply()
    M.apply_transparency()
    vim.notify('Theme reloaded: ' .. colorscheme)
  end, { desc = 'Re-read ~/.config/theme and re-apply the colorscheme' })
end

return M
