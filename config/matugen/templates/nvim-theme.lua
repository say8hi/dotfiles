-- Matugen theme for mini.base16

local base16 = require('mini.base16')
local shared = require('colors._shared')

local diff_palette = {
  add    = { bg = '{{colors.tertiary_container.default.hex}}', fg = '{{colors.on_tertiary_container.default.hex}}' },
  delete = { bg = '{{colors.error_container.default.hex}}',    fg = '{{colors.on_error_container.default.hex}}' },
  change = { bg = '{{colors.primary_container.default.hex}}' },
  text   = { bg = '{{colors.secondary_container.default.hex}}' },
}

-- Base16 palette from matugen
local palette = {
  base00 = '{{colors.background.default.hex}}', -- background
  base01 = '{{colors.surface.default.hex}}', -- lighter background
  base02 = '{{colors.surface_dim.default.hex}}', -- selection
  base03 = '{{colors.surface_variant.default.hex}}', -- comments, line numbers
  base04 = '{{colors.on_surface_variant.default.hex}}', -- dark foreground
  base05 = '{{colors.on_surface.default.hex}}', -- foreground
  base06 = '{{colors.on_surface.default.hex | lighten: 5.0}}', -- light foreground
  base07 = '{{colors.on_surface.default.hex | lighten: 10.0}}', -- lightest
  base08 = '{{colors.error.default.hex}}', -- red (variables, errors)
  base09 = '{{colors.secondary.default.hex | lighten: -10.0}}', -- orange
  base0A = '{{colors.secondary.default.hex}}', -- yellow
  base0B = '{{colors.tertiary.default.hex}}', -- green (strings)
  base0C = '{{colors.primary_fixed.default.hex}}', -- cyan (operators)
  base0D = '{{colors.primary.default.hex}}', -- blue (functions)
  base0E = '{{colors.tertiary_fixed.default.hex}}', -- purple (keywords)
  base0F = '{{colors.error.default.hex | lighten: 5.0}}', -- brown
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
  white = '{{colors.on_surface.default.hex}}',
  darker_black = '{{colors.surface_container.default.hex}}',
  black = '{{colors.background.default.hex | lighten: -0.2}}',
  black2 = '{{colors.surface.default.hex}}',
  one_bg = '{{colors.surface_dim.default.hex}}',
  grey = '{{colors.surface_variant.default.hex}}',
  red = '{{colors.error.default.hex}}',
  pink = '{{colors.tertiary_fixed.default.hex}}',
  green = '{{colors.tertiary.default.hex}}',
  blue = '{{colors.primary.default.hex}}',
  orange = '{{colors.secondary.default.hex | lighten: -10.0}}',
  cyan = '{{colors.primary_fixed.default.hex | lighten: 5.0}}',
  teal = '{{colors.primary_fixed.default.hex}}',
  purple = '{{colors.tertiary_fixed.default.hex | lighten: -5.0}}',
  lavender = '{{colors.primary_fixed.default.hex | lighten: 10.0}}',
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
