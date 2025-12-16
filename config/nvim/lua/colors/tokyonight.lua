-- Tokyo Night theme for mini.base16

local base16 = require "mini.base16"

-- Base16 palette based on Tokyo Night
local palette = {
  base00 = "#1a1b26", -- background
  base01 = "#16161e", -- lighter background
  base02 = "#2f3549", -- selection
  base03 = "#444b6a", -- comments, line numbers
  base04 = "#787c99", -- dark foreground
  base05 = "#a9b1d6", -- foreground
  base06 = "#cbccd1", -- light foreground
  base07 = "#d5d6db", -- lightest
  base08 = "#f7768e", -- red (variables, errors)
  base09 = "#ff9e64", -- orange
  base0A = "#e0af68", -- yellow
  base0B = "#9ece6a", -- green (strings)
  base0C = "#73daca", -- cyan (operators)
  base0D = "#7aa2f7", -- blue (functions)
  base0E = "#bb9af7", -- purple (keywords)
  base0F = "#d18616", -- brown
}

base16.setup {
  palette = palette,
  use_cterm = nil,
  plugins = {
    default = true,
    ["echasnovski/mini.nvim"] = true,
  },
}

vim.g.colors_name = "tokyonight"

-- Custom highlight colors
local colors = {
  white = "#a9b1d6",
  darker_black = "#16161e",
  black = "#1a1b26",
  black2 = "#1f2335",
  one_bg = "#24283b",
  grey = "#444b6a",
  red = "#f7768e",
  pink = "#bb9af7",
  green = "#9ece6a",
  blue = "#7aa2f7",
  orange = "#ff9e64",
  cyan = "#73daca",
  teal = "#1abc9c",
  purple = "#9d7cd8",
  lavender = "#c0caf5",
}

local function apply_custom_highlights()
  -- UI highlights
  vim.api.nvim_set_hl(0, "Normal", { bg = colors.black })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = colors.darker_black })
  vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = colors.darker_black })
  vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = colors.darker_black })
  vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = colors.darker_black })
  vim.api.nvim_set_hl(0, "TelescopePrompt", { bg = colors.darker_black })
  vim.api.nvim_set_hl(0, "TelescopeResults", { bg = colors.darker_black })
  vim.api.nvim_set_hl(0, "Pmenu", { bg = colors.black2 })
  vim.api.nvim_set_hl(0, "CmpPmenu", { bg = colors.black2 })
  vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = colors.black2 })
  vim.api.nvim_set_hl(0, "Visual", { bg = colors.grey })
  vim.api.nvim_set_hl(0, "VisualNOS", { bg = colors.grey })

  -- Treesitter highlights
  vim.api.nvim_set_hl(0, "@variable", { fg = colors.white })
  vim.api.nvim_set_hl(0, "@module", { fg = colors.white })
  vim.api.nvim_set_hl(0, "@variable.member", { fg = colors.white })
  vim.api.nvim_set_hl(0, "@property", { fg = colors.teal })
  vim.api.nvim_set_hl(0, "@variable.builtin", { fg = colors.red })
  vim.api.nvim_set_hl(0, "@type.builtin", { fg = colors.purple })
  vim.api.nvim_set_hl(0, "@variable.parameter", { fg = colors.orange })
  vim.api.nvim_set_hl(0, "@operator", { fg = colors.cyan })
  vim.api.nvim_set_hl(0, "@punctuation.delimiter", { fg = colors.cyan })
  vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = colors.cyan })
  vim.api.nvim_set_hl(0, "@punctuation.special", { fg = colors.teal })
  vim.api.nvim_set_hl(0, "@function.macro", { fg = colors.pink })
  vim.api.nvim_set_hl(0, "@keyword.storage", { fg = colors.purple })
  vim.api.nvim_set_hl(0, "@tag.delimiter", { fg = colors.cyan })
  vim.api.nvim_set_hl(0, "@function", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "@constructor", { fg = colors.lavender })
  vim.api.nvim_set_hl(0, "@tag.attribute", { fg = colors.orange })

  -- Syntax highlights
  vim.api.nvim_set_hl(0, "StorageClass", { fg = colors.purple })
  vim.api.nvim_set_hl(0, "Repeat", { fg = colors.purple })
  vim.api.nvim_set_hl(0, "Define", { fg = colors.blue })

  -- Telescope custom
  vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = colors.one_bg, fg = colors.blue })
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

