pcall(function()
  dofile(vim.g.base46_cache .. "syntax")
  dofile(vim.g.base46_cache .. "treesitter")
end)

-- Ensure custom queries directory is in runtimepath
vim.opt.runtimepath:prepend(vim.fn.stdpath("config"))

return {
  ensure_installed = { "python", "go", "lua", "luadoc", "printf", "vim", "vimdoc", "json", "sql" },

  highlight = {
    enable = true,
    use_languagetree = true,
    additional_vim_highlighting = false,
  },

  indent = { enable = true },
}
