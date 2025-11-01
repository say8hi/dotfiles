require("nvchad.configs.lspconfig").defaults()

local base_on_attach = require("nvchad.configs.lspconfig").on_attach
local capabilities = require("nvchad.configs.lspconfig").capabilities

-- enhanced capabilities with folding support
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

-- custom on_attach with nvim-navic integration
local on_attach = function(client, bufnr)
  base_on_attach(client, bufnr)

  -- attach nvim-navic if available
  local navic_ok, navic = pcall(require, "nvim-navic")
  if navic_ok and client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end

  -- enable inlay hints if supported
  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

local util = require "lspconfig.util"

-- GOPLS
vim.lsp.config.gopls = {
  cmd = {"gopls"},
  filetypes = {"go", "gomod", "gowork", "gotmpl"},
  root_markers = {"go.work", "go.mod", ".git"},
  settings = {
    gopls = {
      codelenses = {
        gc_details = false,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      completeUnimported = true,
      usePlaceholders = true,
      staticcheck = true,
      gofumpt = true,
      analyses = {
        unusedparams = true,
        shadow = true,
        nilness = true,
        unusedwrite = true,
      }
    }
  }
}

vim.lsp.enable('gopls')

-- RUFF LSP
vim.lsp.config.ruff = {
  cmd = {"ruff", "server"},
  filetypes = {"python"},
  root_markers = {"pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git"},
}

-- PYRIGHT
vim.lsp.config.pyright = {
  cmd = {"pyright-langserver", "--stdio"},
  filetypes = {"python"},
  root_markers = {"pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git"},
  settings = {
    pyright = {
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
        typeCheckingMode = "basic",
      },
    },
  },
}

-- universal LspAttach autocmd for all servers
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      on_attach(client, args.buf)
    end
  end,
})

vim.lsp.enable('ruff')
vim.lsp.enable('pyright')

-- JSON
vim.lsp.config.jsonls = {
  cmd = {"vscode-json-language-server", "--stdio"},
  filetypes = {"json", "jsonc"},
  root_markers = {".git"},
}

vim.lsp.enable('jsonls')

-- TypeScript/JavaScript
vim.lsp.config.ts_ls = {
  cmd = {"typescript-language-server", "--stdio"},
  filetypes = {"javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx"},
  root_markers = {"package.json", "tsconfig.json", "jsconfig.json", ".git"},
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
}

vim.lsp.enable('ts_ls')

-- HTML
vim.lsp.config.html = {
  cmd = {"vscode-html-language-server", "--stdio"},
  filetypes = {"html"},
  root_markers = {".git"},
}

vim.lsp.enable('html')

-- CSS
vim.lsp.config.cssls = {
  cmd = {"vscode-css-language-server", "--stdio"},
  filetypes = {"css", "scss", "less"},
  root_markers = {".git"},
}

vim.lsp.enable('cssls')

-- SQL
-- sqls is not installed, uncomment when needed
-- vim.lsp.config.sqls = {
--   cmd = {"sqls"},
--   filetypes = {"sql"},
--   root_markers = {".git"},
--   settings = {
--     sqls = {
--       connections = {
--         -- Example connections (customize as needed)
--         -- {
--         --   driver = "postgresql",
--         --   dataSourceName = "host=127.0.0.1 port=5432 user=postgres password=postgres dbname=mydb sslmode=disable",
--         -- },
--         -- {
--         --   driver = "mysql",
--         --   dataSourceName = "user:password@tcp(127.0.0.1:3306)/dbname",
--         -- },
--       },
--     },
--   },
-- }
--
-- vim.lsp.enable('sqls') 
