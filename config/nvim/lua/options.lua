require "nvchad.options"

local opt = vim.opt
local g = vim.g

-- Cursorline
opt.cursorlineopt = "both"

-- Indenting
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2

-- Numbers
opt.relativenumber = true

-- Scrolling
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Undo
opt.undofile = true
opt.undolevels = 10000

-- Update time
opt.updatetime = 250
opt.timeoutlen = 300

-- Completion
opt.completeopt = "menu,menuone,noselect"

-- Line wrapping
opt.wrap = false

-- Folding
opt.foldmethod = "indent"  -- use indent folding by default
opt.foldenable = true      -- enable folding
opt.foldlevel = 99         -- open all folds by default (use zM to close all)
opt.fillchars = {
  fold = " ",
  foldopen = "▾",
  foldclose = "▸",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

-- custom fold text function showing first line
_G.custom_fold_text = function()
  local line = vim.fn.getline(vim.v.foldstart)
  local line_count = vim.v.foldend - vim.v.foldstart + 1
  local suffix = string.format("  %d lines", line_count)
  return line .. suffix
end

vim.o.foldtext = 'v:lua.custom_fold_text()'

-- Better diff
opt.diffopt:append("vertical,algorithm:histogram,indent-heuristic")

-- Performance
opt.lazyredraw = false
opt.ttyfast = true

-- Mouse
opt.mouse = "a"

-- winbar with navic breadcrumbs
vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
