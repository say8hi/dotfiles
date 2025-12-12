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
    golines = {
      prepend_args = { "--max-len=120", "--base-formatter=gofumpt" },
    },
  },
  format_on_save = function(bufnr)
    -- disable format on save for specific filetypes
    local disable_filetypes = { c = true, cpp = true }
    if disable_filetypes[vim.bo[bufnr].filetype] then
      return
    end
    return {
      timeout_ms = 2000,
      lsp_fallback = true,
    }
  end,
}

return options
