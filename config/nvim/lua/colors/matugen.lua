-- Matugen theme for mini.base16

local base16 = require('mini.base16')
local shared = require('colors._shared')

local diff_palette = {
  add    = { bg = '#705c73', fg = '#ffffff' },
  delete = { bg = '#93000a', fg = '#ffdad6' },
  change = { bg = '#536478' },
  text   = { bg = '#414750' },
}

-- Base16 palette from matugen
local palette = {
  base00 = '#131315', -- background
  base01 = '#131315', -- lighter background
  base02 = '#131315', -- selection
  base03 = '#44474c', -- comments, line numbers
  base04 = '#c4c6cd', -- dark foreground
  base05 = '#e4e2e3', -- foreground
  base06 = '#f0eff0', -- light foreground
  base07 = '#fdfcfd', -- lightest
  base08 = '#ffb4ab', -- red (variables, errors)
  base09 = '#a4adbb', -- orange
  base0A = '#c1c7d1', -- yellow
  base0B = '#d8bfd9', -- green (strings)
  base0C = '#d2e4fc', -- cyan (operators)
  base0D = '#b6c8df', -- blue (functions)
  base0E = '#f4daf6', -- purple (keywords)
  base0F = '#ffcbc5', -- brown
}

base16.setup({
  palette = palette,
  use_cterm = nil,
  plugins = {
    default = true,
    ['echasnovski/mini.nvim'] = true,
  },
})

vim.g.colors_name = 'matugen'

-- Custom highlight colors
local colors = {
  white = '#e4e2e3',
  darker_black = '#1f2021',
  black = '#131314',
  black2 = '#131315',
  one_bg = '#131315',
  grey = '#44474c',
  red = '#ffb4ab',
  pink = '#f4daf6',
  green = '#d8bfd9',
  blue = '#b6c8df',
  orange = '#a4adbb',
  cyan = '#eaf2fe',
  teal = '#d2e4fc',
  purple = '#eec5f1',
  lavender = '#ffffff',
}

local function apply_custom_highlights()
  -- UI highlights
  vim.api.nvim_set_hl(0, 'Normal', { bg = colors.black })
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = colors.darker_black })
  vim.api.nvim_set_hl(0, 'NvimTreeNormal', { bg = colors.darker_black })
  vim.api.nvim_set_hl(0, 'NvimTreeNormalNC', { bg = colors.darker_black })
  vim.api.nvim_set_hl(0, 'TelescopeNormal', { bg = colors.darker_black })
  vim.api.nvim_set_hl(0, 'TelescopePrompt', { bg = colors.darker_black })
  vim.api.nvim_set_hl(0, 'TelescopeResults', { bg = colors.darker_black })
  vim.api.nvim_set_hl(0, 'Pmenu', { bg = colors.black2 })
  vim.api.nvim_set_hl(0, 'CmpPmenu', { bg = colors.black2 })
  vim.api.nvim_set_hl(0, 'BlinkCmpMenu', { bg = colors.black2 })
  vim.api.nvim_set_hl(0, 'Visual', { bg = colors.grey })
  vim.api.nvim_set_hl(0, 'VisualNOS', { bg = colors.grey })

  -- Treesitter highlights
  vim.api.nvim_set_hl(0, '@variable', { fg = colors.white })
  vim.api.nvim_set_hl(0, '@module', { fg = colors.white })
  vim.api.nvim_set_hl(0, '@variable.member', { fg = colors.white })
  vim.api.nvim_set_hl(0, '@property', { fg = colors.teal })
  vim.api.nvim_set_hl(0, '@variable.builtin', { fg = colors.red })
  vim.api.nvim_set_hl(0, '@type.builtin', { fg = colors.purple })
  vim.api.nvim_set_hl(0, '@variable.parameter', { fg = colors.orange })
  vim.api.nvim_set_hl(0, '@operator', { fg = colors.cyan })
  vim.api.nvim_set_hl(0, '@punctuation.delimiter', { fg = colors.cyan })
  vim.api.nvim_set_hl(0, '@punctuation.bracket', { fg = colors.cyan })
  vim.api.nvim_set_hl(0, '@punctuation.special', { fg = colors.teal })
  vim.api.nvim_set_hl(0, '@function.macro', { fg = colors.pink })
  vim.api.nvim_set_hl(0, '@keyword.storage', { fg = colors.purple })
  vim.api.nvim_set_hl(0, '@tag.delimiter', { fg = colors.cyan })
  vim.api.nvim_set_hl(0, '@function', { fg = colors.blue })
  vim.api.nvim_set_hl(0, '@constructor', { fg = colors.lavender })
  vim.api.nvim_set_hl(0, '@tag.attribute', { fg = colors.orange })

  -- Syntax highlights
  vim.api.nvim_set_hl(0, 'StorageClass', { fg = colors.purple })
  vim.api.nvim_set_hl(0, 'Repeat', { fg = colors.purple })
  vim.api.nvim_set_hl(0, 'Define', { fg = colors.blue })

  shared.apply_diff(diff_palette)

  -- Telescope custom
  vim.api.nvim_set_hl(0, 'TelescopeSelection', { bg = colors.one_bg, fg = colors.blue })
end

apply_custom_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = apply_custom_highlights,
})

return {
  palette = palette,
  colors = colors,
}
