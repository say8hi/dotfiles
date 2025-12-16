local M = {}

-- Path to settings file
local settings_file = vim.fn.stdpath("config") .. "/lua/settings.lua"

-- Get available themes from colors directory
local function get_available_themes()
  local colors_dir = vim.fn.stdpath("config") .. "/lua/colors"
  local themes = {}

  local files = vim.fn.readdir(colors_dir)

  for _, file in ipairs(files) do
    if file:match("%.lua$") then
      local theme_name = file:gsub("%.lua$", "")
      table.insert(themes, theme_name)
    end
  end

  table.sort(themes)
  return themes
end

-- Switch to a specific theme
function M.switch_theme(theme_name)
  local themes = get_available_themes()
  if not vim.tbl_contains(themes, theme_name) then
    vim.notify("Theme '" .. theme_name .. "' not found", vim.log.levels.ERROR)
    return
  end

  -- Clear module cache to allow reload
  package.loaded["colors." .. theme_name] = nil
  package.loaded["theme"] = nil

  -- Load the theme
  local ok, err = pcall(require, "colors." .. theme_name)
  if not ok then
    vim.notify("Failed to load theme: " .. err, vim.log.levels.ERROR)
    return
  end

  -- Trigger ColorScheme autocmd
  vim.api.nvim_exec_autocmds("ColorScheme", { pattern = theme_name })

  -- Reload lualine with new theme
  local lualine_ok, lualine = pcall(require, "lualine")
  if lualine_ok then
    -- Reload lualine config module
    package.loaded["configs.lualine"] = nil
    local lualine_config = require("configs.lualine")
    lualine.setup(lualine_config.get_config())
  end

  -- Save theme choice to settings.lua
  local content = string.format(
    [[-- User settings

local M = {}

-- Theme selection
M.theme = "%s"

return M
]],
    theme_name
  )

  local file = io.open(settings_file, "w")
  if file then
    file:write(content)
    file:close()
    -- Clear settings module cache
    package.loaded["settings"] = nil
  end

  vim.notify("Switched to " .. theme_name .. " theme", vim.log.levels.INFO)
end

-- Get list of available themes
function M.get_themes()
  return get_available_themes()
end

-- Get saved theme from settings
function M.get_saved_theme()
  local themes = get_available_themes()
  local ok, settings = pcall(require, "settings")
  if ok and settings.theme and vim.tbl_contains(themes, settings.theme) then
    return settings.theme
  end
  return "matugen" -- default theme
end

-- Load saved theme
function M.load_saved_theme()
  local theme = M.get_saved_theme()
  require("colors." .. theme)
end

-- Apply theme without saving (for preview)
local function apply_theme_preview(theme_name)
  -- Clear module cache
  package.loaded["colors." .. theme_name] = nil
  package.loaded["theme"] = nil

  -- Load the theme
  pcall(require, "colors." .. theme_name)

  -- Trigger ColorScheme autocmd
  vim.api.nvim_exec_autocmds("ColorScheme", { pattern = theme_name })

  -- Reload lualine
  local lualine_ok, lualine = pcall(require, "lualine")
  if lualine_ok then
    package.loaded["configs.lualine"] = nil
    local lualine_config = require("configs.lualine")
    lualine.setup(lualine_config.get_config())
  end
end

-- Save theme to settings
local function save_theme(theme_name)
  local content = string.format(
    [[-- User settings

local M = {}

-- Theme selection
M.theme = "%s"

return M
]],
    theme_name
  )

  local file = io.open(settings_file, "w")
  if file then
    file:write(content)
    file:close()
    package.loaded["settings"] = nil
  end
end

-- Select theme using Telescope with live preview
function M.select_theme()
  local themes = get_available_themes()
  local current_theme = M.get_saved_theme()

  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  -- Find index of current theme
  local default_index = 1
  for i, theme in ipairs(themes) do
    if theme == current_theme then
      default_index = i
      break
    end
  end

  pickers
    .new({}, {
      prompt_title = "Select Theme",
      finder = finders.new_table {
        results = themes,
      },
      sorter = conf.generic_sorter {},
      layout_strategy = "center",
      layout_config = {
        width = 0.3,
        height = 0.4,
      },
      default_selection_index = default_index,
      attach_mappings = function(prompt_bufnr, map)
        -- Preview on cursor move
        local function preview_theme()
          local selection = action_state.get_selected_entry()
          if selection then
            apply_theme_preview(selection[1])
          end
        end

        -- Override default select action
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if selection then
            apply_theme_preview(selection[1])
            save_theme(selection[1])
            vim.notify("Theme set to " .. selection[1], vim.log.levels.INFO)
          end
        end)

        -- Restore original theme on cancel
        map("i", "<esc>", function()
          actions.close(prompt_bufnr)
          apply_theme_preview(current_theme)
        end)

        map("n", "q", function()
          actions.close(prompt_bufnr)
          apply_theme_preview(current_theme)
        end)

        -- Preview on cursor move
        map("i", "<Down>", function()
          actions.move_selection_next(prompt_bufnr)
          preview_theme()
        end)

        map("i", "<Up>", function()
          actions.move_selection_previous(prompt_bufnr)
          preview_theme()
        end)

        map("i", "<C-n>", function()
          actions.move_selection_next(prompt_bufnr)
          preview_theme()
        end)

        map("i", "<C-p>", function()
          actions.move_selection_previous(prompt_bufnr)
          preview_theme()
        end)

        map("n", "j", function()
          actions.move_selection_next(prompt_bufnr)
          preview_theme()
        end)

        map("n", "k", function()
          actions.move_selection_previous(prompt_bufnr)
          preview_theme()
        end)

        -- Preview initial selection
        vim.defer_fn(preview_theme, 10)

        return true
      end,
    })
    :find()
end

return M
