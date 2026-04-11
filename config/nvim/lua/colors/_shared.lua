-- Shared highlight helpers used by color schemes in this directory.
-- Each theme passes its own palette; this module only wires names to colors.

local M = {}

-- Diff highlights (native Neovim diff / claudecode.nvim)
-- palette = { add = { bg, fg }, delete = { bg, fg }, change = { bg }, text = { bg } }
function M.apply_diff(p)
  vim.api.nvim_set_hl(0, "DiffAdd",    { bg = p.add.bg,    fg = p.add.fg })
  vim.api.nvim_set_hl(0, "DiffDelete", { bg = p.delete.bg, fg = p.delete.fg })
  vim.api.nvim_set_hl(0, "DiffChange", { bg = p.change.bg })
  vim.api.nvim_set_hl(0, "DiffText",   { bg = p.text.bg, bold = true })
end

-- Bufferline highlights
-- palette = {
--   bg, bg_sel, fill,
--   fg_inactive, fg_visible, fg_selected,
--   modified, warning, error,
-- }
function M.apply_bufferline(p)
  local bg, bg_sel, fill = p.bg, p.bg_sel, p.fill
  local set = function(name, val) vim.api.nvim_set_hl(0, name, val) end

  set("BufferLineBackground",              { fg = p.fg_inactive, bg = bg })
  set("BufferLineFill",                    { bg = fill })
  set("BufferLineBufferSelected",          { fg = p.fg_selected, bg = bg_sel, bold = true })
  set("BufferLineBufferVisible",           { fg = p.fg_visible,  bg = bg })

  set("BufferLineSeparator",               { fg = fill, bg = bg })
  set("BufferLineSeparatorSelected",       { fg = fill, bg = bg_sel })
  set("BufferLineSeparatorVisible",        { fg = fill, bg = bg })

  set("BufferLineCloseButton",             { fg = p.fg_inactive, bg = bg })
  set("BufferLineCloseButtonSelected",     { fg = p.fg_selected, bg = bg_sel })
  set("BufferLineCloseButtonVisible",      { fg = p.fg_visible,  bg = bg })

  set("BufferLineModified",                { fg = p.modified, bg = bg })
  set("BufferLineModifiedSelected",        { fg = p.modified, bg = bg_sel })
  set("BufferLineModifiedVisible",         { fg = p.modified, bg = bg })

  set("BufferLineDiagnostic",              { fg = p.fg_inactive, bg = bg })
  set("BufferLineDiagnosticSelected",      { fg = p.fg_visible,  bg = bg_sel })

  set("BufferLineError",                   { fg = p.error, bg = bg })
  set("BufferLineErrorSelected",           { fg = p.error, bg = bg_sel })
  set("BufferLineErrorDiagnostic",         { fg = p.error, bg = bg })
  set("BufferLineErrorDiagnosticSelected", { fg = p.error, bg = bg_sel })

  set("BufferLineWarning",                 { fg = p.warning, bg = bg })
  set("BufferLineWarningSelected",         { fg = p.warning, bg = bg_sel })
  set("BufferLineWarningDiagnostic",       { fg = p.warning, bg = bg })
  set("BufferLineWarningDiagnosticSelected",{ fg = p.warning, bg = bg_sel })
end

-- Repaint BufferLineDevIcon* groups so they sit on the bufferline background.
-- palette = { bg, bg_sel }
function M.fix_bufferline_devicons(p)
  for _, hl in ipairs(vim.fn.getcompletion("BufferLineDevIcon", "highlight")) do
    local ok, existing = pcall(vim.api.nvim_get_hl, 0, { name = hl, link = false })
    if ok and existing then
      local bg = hl:match("Selected$") and p.bg_sel or p.bg
      vim.api.nvim_set_hl(0, hl, { fg = existing.fg, bg = bg })
    end
  end
end

return M
