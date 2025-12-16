local M = {}

local function enter_inside_quotes()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before = line:sub(1, col)
  local after = line:sub(col + 1)
  local is_f_string = before:match('.*f"') and after:match('"') or before:match(".*f'") and after:match("'")
  local is_regular_string = before:match('"') and after:match('"') or before:match("'") and after:match("'")
  if is_f_string or is_regular_string then
    local quote = is_f_string and 'f"' or '"'
    local new_line = '"' .. '<CR>' .. quote
    local key_strokes = vim.api.nvim_replace_termcodes(new_line, true, false, true)
    vim.api.nvim_feedkeys(key_strokes, 'n', true)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', true)
  end
end

function M.enter_inside_quotes()
  enter_inside_quotes()
end

return M