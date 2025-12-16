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

-- Theme reload command (useful for matugen hooks)
vim.api.nvim_create_user_command("ThemeReload", function()
  local settings = require "settings"
  local theme_name = settings.theme

  -- clear module cache for color files
  package.loaded["colors." .. theme_name] = nil
  package.loaded["theme"] = nil

  -- load the theme
  local ok, err = pcall(require, "colors." .. theme_name)
  if not ok then
    vim.notify("Failed to reload theme: " .. err, vim.log.levels.ERROR)
    return
  end

  -- trigger ColorScheme autocmd
  vim.api.nvim_exec_autocmds("ColorScheme", { pattern = theme_name })

  -- reload lualine if available
  local lualine_ok, lualine = pcall(require, "lualine")
  if lualine_ok then
    package.loaded["configs.lualine"] = nil
    local lualine_config = require "configs.lualine"
    lualine.setup(lualine_config.get_config())
  end

  vim.notify("Theme reloaded: " .. theme_name, vim.log.levels.INFO)
end, {
  desc = "Reload current theme (clears cache and reapplies colors)",
})
