local M = {}

-- Terminal state
M.terminals = {
  horizontal = { buf = nil, win = nil },
  vertical = { buf = nil, win = nil },
  float = { buf = nil, win = nil },
}

-- Check if buffer is valid and exists
local function buf_valid(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

-- Check if window is valid and exists
local function win_valid(win)
  return win and vim.api.nvim_win_is_valid(win)
end

-- Toggle terminal helper
local function toggle_term(term_type, open_fn)
  local term = M.terminals[term_type]

  -- If terminal window is open, close it
  if win_valid(term.win) then
    vim.api.nvim_win_close(term.win, true)
    term.win = nil
    return
  end

  -- If buffer exists but window is closed, reopen it
  if buf_valid(term.buf) then
    open_fn(term.buf)
  else
    -- Create new terminal buffer
    local buf = vim.api.nvim_create_buf(false, true)
    term.buf = buf
    open_fn(buf)
    vim.fn.termopen(vim.o.shell)
  end

  vim.cmd("startinsert")
end

-- Open terminal in horizontal split
function M.horizontal()
  toggle_term("horizontal", function(buf)
    vim.cmd("split")
    vim.cmd("resize 15")
    vim.api.nvim_win_set_buf(0, buf)
    M.terminals.horizontal.win = vim.api.nvim_get_current_win()
  end)
end

-- Open terminal in vertical split
function M.vertical()
  toggle_term("vertical", function(buf)
    vim.cmd("vsplit")
    vim.cmd("vertical resize 80")
    vim.api.nvim_win_set_buf(0, buf)
    M.terminals.vertical.win = vim.api.nvim_get_current_win()
  end)
end

-- Open terminal in floating window
function M.float()
  toggle_term("float", function(buf)
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = "rounded",
    })

    M.terminals.float.win = win
  end)
end

return M