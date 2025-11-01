require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd

-- auto save on focus lost
autocmd("FocusLost", {
  pattern = "*",
  command = "silent! wa",
})

-- highlight on yank
autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank {
      higroup = "IncSearch",
      timeout = 200,
    }
  end,
})

-- close some windows with q
autocmd("FileType", {
  pattern = {
    "help",
    "qf",
    "lspinfo",
    "checkhealth",
    "man",
    "notify",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- auto open quickfix after grep
autocmd("QuickFixCmdPost", {
  pattern = "[^l]*",
  command = "cwindow",
})

autocmd("QuickFixCmdPost", {
  pattern = "l*",
  command = "lwindow",
})

-- optimize for large files
autocmd("BufReadPre", {
  pattern = "*",
  callback = function()
    local max_filesize = 100 * 1024 -- 100 KB
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
    if ok and stats and stats.size > max_filesize then
      vim.b.large_file = true
      vim.cmd "syntax clear"
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.spell = false
    end
  end,
})

-- auto create directories when saving
autocmd("BufWritePre", {
  pattern = "*",
  callback = function(event)
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- restore cursor position when opening file
autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- enable treesitter folding for supported filetypes
autocmd("FileType", {
  pattern = {
    "lua",
    "python",
    "go",
    "javascript",
    "typescript",
    "typescriptreact",
    "javascriptreact",
    "rust",
    "c",
    "cpp",
    "java",
    "php",
    "ruby",
  },
  callback = function()
    -- check if treesitter parser is available
    local has_parser = pcall(vim.treesitter.get_parser, 0)
    if has_parser then
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    else
      -- fallback to indent folding
      vim.wo.foldmethod = "indent"
    end
    vim.wo.foldenable = true
    vim.wo.foldlevel = 99
  end,
})

-- auto reload theme when matugen theme file changes
local theme_file = vim.fn.stdpath "data" .. "/lazy/base46/lua/base46/themes/matugen.lua"

-- reload theme function
local function reload_theme()
  -- clear lua module cache for theme
  package.loaded["base46.themes.matugen"] = nil

  -- reload base46 highlights
  local ok, base46 = pcall(require, "base46")
  if ok then
    base46.load_all_highlights()
    vim.notify("matugen theme reloaded", vim.log.levels.INFO)
  end
end

-- watch theme file for changes
local watcher = vim.loop.new_fs_event()
if watcher then
  watcher:start(
    theme_file,
    {},
    vim.schedule_wrap(function()
      reload_theme()
    end)
  )
end

-- also reload on manual save
autocmd("BufWritePost", {
  pattern = theme_file,
  callback = reload_theme,
})
