-- Lualine configuration

local M = {}

function M.get_config()
  local theme = require "theme"

  -- lsp clients component
  local lsp_clients = {
    function()
      local clients = vim.lsp.get_clients { bufnr = 0 }
      if #clients == 0 then
        return ""
      end

      local client_names = {}
      for _, client in ipairs(clients) do
        table.insert(client_names, client.name)
      end
      return "LSP: " .. table.concat(client_names, ", ")
    end,
  }

  return {
    options = {
      icons_enabled = true,
      theme = theme.get_lualine_theme(),
      component_separators = { left = "|", right = "|" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = {
        statusline = { "dashboard", "alpha", "starter", "snacks_dashboard" },
        winbar = {},
      },
      ignore_focus = {},
      always_divide_middle = true,
      globalstatus = true,
      refresh = {
        statusline = 100,
        tabline = 100,
        winbar = 100,
      },
    },
    sections = {
      lualine_a = {
        {
          "mode",
          fmt = function(str)
            return " " .. str
          end,
        },
      },
      lualine_b = {
        "branch",
        {
          "diff",
          symbols = { added = "+", modified = "~", removed = "-" },
        },
      },
      lualine_c = {
        {
          "filename",
          path = 1, -- relative path
          symbols = {
            modified = "●",
            readonly = "",
            unnamed = "[No Name]",
            newfile = "[New]",
          },
        },
      },
      lualine_x = {
        {
          "diagnostics",
          sources = { "nvim_lsp" },
          symbols = { error = "E:", warn = "W:", info = "I:", hint = "H:" },
        },
        lsp_clients,
      },
      lualine_y = {
        "filetype",
        {
          "encoding",
          cond = function()
            return vim.bo.fileencoding ~= "utf-8"
          end,
        },
        {
          "fileformat",
          symbols = {
            unix = "LF",
            dos = "CRLF",
            mac = "CR",
          },
          cond = function()
            return vim.bo.fileformat ~= "unix"
          end,
        },
      },
      lualine_z = { "progress", "location" },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {
        {
          "filename",
          path = 1,
        },
      },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = { "nvim-tree", "lazy", "mason", "trouble", "nvim-dap-ui" },
  }
end

return M

