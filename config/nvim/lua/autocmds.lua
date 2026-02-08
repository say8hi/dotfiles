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
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(0))
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
    local file = vim.uv.fs_realpath(event.match) or event.match
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

-- ufo folding compatibility - ensure fold settings are set correctly
autocmd("FileType", {
  pattern = "*",
  callback = function()
    -- these settings work with nvim-ufo
    vim.wo.foldlevel = 99
    vim.wo.foldenable = true
  end,
})
