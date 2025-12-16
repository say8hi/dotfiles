local opt = vim.opt
local o = vim.o
local g = vim.g

-- UI
o.laststatus = 3          -- global statusline
o.showmode = false        -- don't show mode (already in statusline)
o.splitkeep = "screen"    -- keep screen position when splitting

-- Cursorline
o.cursorline = true
opt.cursorlineopt = "both"

-- Indenting
o.expandtab = true        -- use spaces instead of tabs
o.smartindent = true      -- smart autoindenting
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2

-- Numbers
o.number = true           -- show line numbers
o.numberwidth = 2         -- width of number column
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

-- Signcolumn
o.signcolumn = "yes"      -- always show signcolumn

-- Disable intro screen
opt.shortmess:append "sI"

-- Allow cursor to move where there is no text in visual block mode
opt.whichwrap:append "<>[]hl"

-- Disable some default providers (performance)
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

-- Add Mason binaries to PATH
local is_windows = vim.fn.has "win32" ~= 0
local sep = is_windows and "\\" or "/"
local delim = is_windows and ";" or ":"
vim.env.PATH = table.concat({ vim.fn.stdpath "data", "mason", "bin" }, sep) .. delim .. vim.env.PATH

-- Diagnostics configuration
vim.diagnostic.config {
  virtual_text = {
    prefix = "●",
    spacing = 4,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
    focusable = false,
  },
}
