-- User commands

-- MasonInstallAll command
vim.api.nvim_create_user_command("MasonInstallAll", function()
  -- Get ensure_installed list from lazy.nvim config
  local ensure_installed = {
    "gopls",
    "prettier",
    "debugpy",
    "ruff",
    "pyright",
    "html-lsp",
    "css-lsp",
    "typescript-language-server",
    "json-lsp",
    "lua-language-server",
    "rust-analyzer",
    "stylua",
    "gofumpt",
    "goimports-reviser",
    "golines",
    "black",
    "sqls",
  }

  vim.cmd "Mason"

  local mr = require "mason-registry"

  for _, tool in ipairs(ensure_installed) do
    local p = mr.get_package(tool)
    if not p:is_installed() then
      p:install()
    end
  end
end, {
  desc = "Install all Mason packages from ensure_installed",
})

-- Theme switcher command
vim.api.nvim_create_user_command("ThemeSwitch", function(opts)
  local theme_switcher = require "scripts.theme_switcher"
  if opts.args ~= "" then
    theme_switcher.switch_theme(opts.args)
  else
    theme_switcher.select_theme()
  end
end, {
  nargs = "?",
  complete = function()
    return require("scripts.theme_switcher").get_themes()
  end,
  desc = "Switch colorscheme theme",
})
