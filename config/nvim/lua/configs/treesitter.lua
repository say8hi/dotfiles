-- Ensure custom queries directory is in runtimepath
vim.opt.runtimepath:prepend(vim.fn.stdpath("config"))

return {
  ensure_installed = { "python", "go", "lua", "luadoc", "printf", "vim", "vimdoc", "json", "sql", "rust" },

  highlight = {
    enable = true,
    use_languagetree = true,
    additional_vim_highlighting = false,
  },

  indent = { enable = true },
}
