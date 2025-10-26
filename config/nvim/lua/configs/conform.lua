local options = {
  formatters_by_ft = {
    go = { "gofumpt", "goimports-reviser", "golines" },
    python = { "ruff_format", "ruff_organize_imports" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    json = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    lua = { "stylua" },
    sql = { "sqlfluff" },
  },
  formatters = {
    sqlfluff = {
      args = { "format", "--dialect=postgres", "--nocolor", "-" },
      stdin = true,
    },
  },
  format_on_save = {
    timeout_ms = 2000,
    lsp_fallback = true,
  },
}

return options
