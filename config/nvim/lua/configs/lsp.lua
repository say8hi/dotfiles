local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

local function on_init(client, _)
  if client.supports_method "textDocument/semanticTokens" then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

local function on_attach(client, bufnr)
  local navic_ok, navic = pcall(require, "nvim-navic")
  if navic_ok and client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end

  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

local function make_config(cmd, filetypes, root_markers, settings)
  return {
    cmd = cmd,
    filetypes = filetypes,
    root_markers = root_markers,
    capabilities = capabilities,
    on_init = on_init,
    on_attach = on_attach,
    settings = settings,
  }
end

vim.lsp.config.gopls = make_config(
  { "gopls" },
  { "go", "gomod", "gowork", "gotmpl" },
  { ".git", "go.mod" },
  {
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
      },
    },
  }
)

vim.lsp.config.ruff = make_config(
  { "ruff", "server" },
  { "python" },
  { ".git", "pyproject.toml", "setup.py" }
)

vim.lsp.config.pyright = make_config(
  { "pyright-langserver", "--stdio" },
  { "python" },
  { ".git", "pyproject.toml", "setup.py" },
  {
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
  }
)

vim.lsp.config.jsonls = make_config(
  { "vscode-json-language-server", "--stdio" },
  { "json", "jsonc" },
  { ".git" }
)

vim.lsp.config.ts_ls = make_config(
  { "typescript-language-server", "--stdio" },
  { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  { ".git", "package.json" },
  {
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
  }
)

vim.lsp.config.html = make_config(
  { "vscode-html-language-server", "--stdio" },
  { "html" },
  { ".git" }
)

vim.lsp.config.cssls = make_config(
  { "vscode-css-language-server", "--stdio" },
  { "css", "scss", "less" },
  { ".git" }
)

vim.lsp.config.sqls = make_config(
  { "sqls" },
  { "sql", "mysql", "plsql" },
  { ".git" }
)

vim.lsp.config.lua_ls = make_config(
  { "lua-language-server" },
  { "lua" },
  { ".git", ".luarc.json", ".stylua.toml" },
  {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          vim.env.VIMRUNTIME,
          "${3rd}/luv/library",
        },
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  }
)

vim.lsp.config.rust_analyzer = make_config(
  { "rust-analyzer" },
  { "rust" },
  { "Cargo.toml", ".git" },
  {
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy",
      },
      inlayHints = {
        chainingHints = { enable = true },
        parameterHints = { enable = true },
        typeHints = { enable = true },
      },
      cargo = {
        allFeatures = true,
      },
      procMacro = {
        enable = true,
      },
    },
  }
)

local servers = { "gopls", "ruff", "pyright", "jsonls", "ts_ls", "html", "cssls", "sqls", "lua_ls", "rust_analyzer" }
for _, server in ipairs(servers) do
  vim.lsp.enable(server)
end