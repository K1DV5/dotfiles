-- custom lsp config

------------------ DIAGNOSTICS ----------------------

vim.diagnostic.config({
    update_in_insert = false,
    virtual_text = false,
    jump = {
        float = true,
    }
    -- float = {
    --     scope = 'line',
    --     source = 'if_many',
    -- },
})

-------------------- SETUP ------------------------

-- range formatting
local function format_range_operator()
    local has_range = false
    for _, server in ipairs(vim.lsp.get_clients({buffer = 0})) do
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

local illuminate = require 'illuminate'
-- setup func
local function on_attach(client, bufnr)
    -- Mappings
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr })
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
    vim.keymap.set('i', '<c-k>', vim.lsp.buf.signature_help, { buffer = bufnr })
    vim.keymap.set('n', 'gq', format_range_operator, { buffer = bufnr })

    illuminate.on_attach(client)
    vim.keymap.set('n', '<a-n>', function() illuminate.next_reference { wrap = true } end, {buffer = bufnr })
    vim.keymap.set('n', '<a-p>', function() illuminate.next_reference { reverse = true, wrap = true } end, {buffer = bufnr })
end

-- change diagnostic signs shown in sign column
vim.fn.sign_define("DiagnosticSignError", { text = '', texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = '', texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = '', texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = '', texthl = "DiagnosticSignHint" })

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
        root_markers = {'pyproject.toml', 'ruff.toml', '.ruff.toml'},
        single_file_support = true,
    },
    html = {
        'html-lsp',
        cmd = { 'vscode-html-language-server', '--stdio' },
        filetypes = { 'html', 'templ' },
        root_markers = {'package.json', '.git'},
        single_file_support = true,
        settings = {},
        init_options = {
          provideFormatter = true,
          embeddedLanguages = { css = true, javascript = true },
          configurationSection = { 'html', 'css', 'javascript' },
        },
    },
    cssls = {
        'css-lsp',
        cmd = { 'vscode-css-language-server', '--stdio' },
        filetypes = { 'css', 'scss', 'less' },
        init_options = { provideFormatter = true }, -- needed to enable formatting capabilities
        root_markers = {'package.json', '.git'},
        single_file_support = true,
        settings = {
          css = { validate = true },
          scss = { validate = true },
          less = { validate = true },
        },
    },
    ts_ls = {
        'typescript-language-server',
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
        root_markers = {'tsconfig.json', 'jsconfig.json', 'package.json', '.git'},
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
        root_markers = {'.git'},
        single_file_support = true,
    },
    gopls = {
        cmd = { 'gopls' },
        filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
        root_markers = {'go.work', 'go.mod', '.git'},
        single_file_support = true,
    },
    lua_ls = {
        'lua-language-server',
        cmd = { 'lua-language-server' },
        single_file_support = true,
        log_level = vim.lsp.protocol.MessageType.Warning,
        filetypes = { "lua" },
        root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
        on_init = function(client)
            if client.workspace_folders then
                local path = client.workspace_folders[1].name
                ---@diagnostic disable-next-line: undefined-field
                if path ~= vim.fn.stdpath('config') and (vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc')) then
                    return
                end
            end

            client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                runtime = {
                    -- Tell the language server which version of Lua you're using
                    -- (most likely LuaJIT in the case of Neovim)
                    version = 'LuaJIT'
                },
                -- Make the server aware of Neovim runtime files
                workspace = {
                    checkThirdParty = false,
                    library = {
                        vim.env.VIMRUNTIME
                        -- Depending on the usage, you might want to add additional paths here.
                        -- "${3rd}/luv/library"
                        -- "${3rd}/busted/library",
                    }
                    -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
                    -- library = vim.api.nvim_get_runtime_file("", true)
                }
            })
        end,
        settings = {
            Lua = {}
        }
    },
}

local mason_reg = require'mason-registry'
-- enable snippets support on client
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local is_installed = {}
for _, name in ipairs(mason_reg.get_installed_package_names()) do
    is_installed[name] = true
end

for name, opts in pairs(servers) do
    local mason_name = opts[1]
    if mason_name == nil then
        mason_name = name
    end
    if is_installed[mason_name] then
        vim.lsp.config[name] = vim.tbl_extend('keep', opts, {
            capabilities = capabilities,
            on_attach = on_attach,
            flags = {
                debounce_text_changes = 150
            }
        })
        vim.lsp.enable{name}
        is_installed[mason_name] = false  -- to check which is not set up below
    end
end

for name, inst in pairs(is_installed) do
    if inst then
        print('LSP server', name, 'can be removed')
    end
end

-- inlay hints have to be enabled as well
vim.lsp.inlay_hint.enable()
