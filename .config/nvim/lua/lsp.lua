-- custom lsp config

local illuminate = require 'illuminate'
local cmp_nvim_lsp = require('cmp_nvim_lsp')

------------------ DIAGNOSTICS ----------------------

local diagnostic_config = {
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.INFO] = '',
      [vim.diagnostic.severity.HINT] = '',
    },
  },
  update_in_insert = false,
  float = {
    scope = 'line',
    source = 'if_many',
    header = '',
  },
  jump = {
    float = true,
  }
}

-------------------- SETUP ------------------------

local function restart_buffer_clients()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  vim.lsp.stop_client(clients)
  for _, client in ipairs(clients) do
    vim.lsp.start(client.config, {
      reuse_client = function()
        return false
      end
    })
  end
end

-- range formatting
local function format_range_operator()
  local has_range = false
  for _, server in ipairs(vim.lsp.get_clients({ buffer = 0 })) do
    if server.server_capabilities.documentRangeFormattingProvider == true then
      has_range = true
    end
  end
  if not has_range then
    vim.lsp.buf.format { async = true }
    return
  end
  local old_func = vim.go.operatorfunc
  _G.op_func_format = function()
    local start = vim.api.nvim_buf_get_mark(0, '[')
    local finish = vim.api.nvim_buf_get_mark(0, ']')
    vim.lsp.buf.format { async = true, range = { start = start, ["end"] = finish } }
    vim.go.operatorfunc = old_func
    _G.op_func_format = nil
  end
  vim.o.operatorfunc = 'v:lua.op_func_format'
  vim.api.nvim_feedkeys('g@', 'n', false)
end

-- setup func
local function on_attach(client, bufnr)
  -- Mappings
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr })
  vim.keymap.set('n', 'gD', vim.lsp.buf.implementation, { buffer = bufnr })
  vim.keymap.set('n', '<c-]>', vim.lsp.buf.declaration, { buffer = bufnr })
  vim.keymap.set('n', '1gD', vim.lsp.buf.type_definition, { buffer = bufnr })
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
  vim.keymap.set('i', '<c-k>', vim.lsp.buf.signature_help, { buffer = bufnr })
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = bufnr })
  vim.keymap.set('n', '<f2>', vim.lsp.buf.rename, { buffer = bufnr })
  vim.keymap.set('n', 'ga', vim.lsp.buf.code_action, { buffer = bufnr })
  vim.keymap.set('n', 'gq', format_range_operator, { buffer = bufnr })
  vim.keymap.set('n', 'gx', restart_buffer_clients, { buffer = bufnr })
  vim.keymap.set('n', '<leader>d', function ()
    local count = vim.diagnostic.count(0, {lnum = vim.fn.line('.')})
    if #count > 0 then
      vim.diagnostic.open_float()
    else
      vim.diagnostic.jump{count = 1, float = true}
    end
  end, { buffer = bufnr })

  illuminate.on_attach(client)
  vim.keymap.set('n', '<a-n>', function() illuminate.next_reference { wrap = true } end, { buffer = bufnr })
  vim.keymap.set('n', '<a-p>', function() illuminate.next_reference { reverse = true, wrap = true } end, { buffer = bufnr })
end

-- setup language servers
local servers = {
  pyright = {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { 'python' },
    root_markers = {
      'pyproject.toml',
      'setup.py',
      'setup.cfg',
      'requirements.txt',
      'Pipfile',
      'pyrightconfig.json',
      '.git',
    },
    single_file_support = true,
    settings = {
      pyright = {
        autoImportCompletion = true,
      },
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = 'openFilesOnly',
          useLibraryCodeForTypes = true,
          typeCheckingMode = 'off',
        }
      }
    }
  },
  ruff = {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml' },
    single_file_support = true,
  },
  html = {
    cmd = { 'vscode-html-language-server', '--stdio' },
    filetypes = { 'html', 'templ' },
    root_markers = { 'package.json', '.git' },
    single_file_support = true,
    settings = {},
    init_options = {
      provideFormatter = true,
      embeddedLanguages = { css = true, javascript = true },
      configurationSection = { 'html', 'css', 'javascript' },
    },
  },
  cssls = {
    cmd = { 'vscode-css-language-server', '--stdio' },
    filetypes = { 'css', 'scss', 'less' },
    init_options = { provideFormatter = true },     -- needed to enable formatting capabilities
    root_markers = { 'package.json', '.git' },
    single_file_support = true,
    settings = {
      css = { validate = true },
      scss = { validate = true },
      less = { validate = true },
    },
  },
  ts_ls = {
    init_options = { hostInfo = 'neovim' },
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = {
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx',
    },
    root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
    single_file_support = true,
  },
  biome = {
    cmd = { 'biome', 'lsp-proxy' },
    filetypes = {
      'astro',
      'css',
      'graphql',
      'javascript',
      'javascriptreact',
      'json',
      'jsonc',
      'svelte',
      'typescript',
      'typescript.tsx',
      'typescriptreact',
      'vue',
    },
    root_markers = { 'biome.json', 'biome.jsonc' },
    single_file_support = false,
  },
  tinymist = {
    cmd = { 'tinymist' },
    filetypes = { 'typst' },
    single_file_support = true,
  },
  jsonls = {
    'json-lsp',
    cmd = { 'vscode-json-language-server', '--stdio' },
    filetypes = { 'json', 'jsonc' },
    init_options = {
      provideFormatter = true,
    },
    root_markers = { '.git' },
    single_file_support = true,
  },
  gopls = {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_markers = { 'go.work', 'go.mod', '.git' },
    single_file_support = true,
  },
  lua_ls = {
    cmd = { 'lua-language-server' },
    single_file_support = true,
    log_level = vim.lsp.protocol.MessageType.Warning,
    filetypes = { "lua" },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        ---@diagnostic disable-next-line: undefined-field
        if path ~= vim.fn.stdpath('config') and (vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc')) then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          version = 'LuaJIT'
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME
          }
        }
      })
    end,
    settings = {
      Lua = {}
    }
  },
}

local M = {}

function M.setup()
  -- config diagnostics
  vim.diagnostic.config(diagnostic_config)
  -- enable inlay hints
  vim.lsp.inlay_hint.enable()
  -- common config
  local capabilities = cmp_nvim_lsp.default_capabilities()
  local default_opts = {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150
    }
  }
  -- setup servers
  local names = {}
  for name, opts in pairs(servers) do
    if vim.fn.executable(opts.cmd[1]) then
      vim.lsp.config[name] = vim.tbl_extend('keep', opts, default_opts)
      table.insert(names, name)
    end
  end
  vim.lsp.enable(names)
end

return M
