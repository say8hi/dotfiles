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

-- Folding (managed by nvim-ufo plugin)
opt.fillchars = {
  fold = " ",
  foldopen = "▾",
  foldclose = "▸",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

-- Better diff
opt.diffopt:append("vertical,algorithm:histogram,indent-heuristic")

-- Performance
opt.lazyredraw = false -- disabled due to conflict with noice.nvim/snacks.nvim
opt.ttyfast = true

-- Mouse
opt.mouse = "a"

-- winbar with navic breadcrumbs
vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
