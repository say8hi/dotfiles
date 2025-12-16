-- Central theme configuration
-- This module provides theme colors to all UI components (lualine, barbecue, etc)

local M = {}

-- Get theme colors based on current colorscheme
function M.get_colors()
  -- Try to load from current colorscheme module
  local colorscheme = vim.g.colors_name or "default"

  -- Check if colorscheme has custom colors module
  local ok, colors_module = pcall(require, "colors." .. colorscheme)
  if ok and colors_module.colors then
    return colors_module.colors, colors_module.palette
  end

  -- Fallback: read from highlight groups
  return nil, nil
end

-- Generate lualine theme from current colors
function M.get_lualine_theme()
  local colors, palette = M.get_colors()

  if not colors then
    return "auto"
  end

  return {
    normal = {
      a = { fg = colors.black, bg = colors.blue, gui = 'bold' },
      b = { fg = colors.white, bg = colors.grey },
      c = { fg = colors.white, bg = colors.black },
    },
    insert = {
      a = { fg = colors.black, bg = colors.green, gui = 'bold' },
    },
    visual = {
      a = { fg = colors.black, bg = colors.pink, gui = 'bold' },
    },
    replace = {
      a = { fg = colors.black, bg = colors.red, gui = 'bold' },
    },
    command = {
      a = { fg = colors.black, bg = (palette and palette.base0A) or colors.blue, gui = 'bold' },
    },
    inactive = {
      a = { fg = colors.white, bg = colors.grey },
      b = { fg = colors.white, bg = colors.grey },
      c = { fg = colors.grey, bg = colors.black },
    },
  }
end

return M