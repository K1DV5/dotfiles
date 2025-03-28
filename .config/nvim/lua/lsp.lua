-- custom lsp config

------------------ DIAGNOSTICS ----------------------

-- -- used with autocmd below
-- local function show_diagnostics()
--     vim.diagnostic.open_float({ focusable = false, scope = 'line' })
-- end

vim.diagnostic.config({
    update_in_insert = false,
    -- virtual_text = false,
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
    vim.keymap.set('n', '<c-]>', vim.lsp.buf.declaration, { buffer = bufnr })
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr })
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
    vim.keymap.set('n', 'gD', vim.lsp.buf.implementation, { buffer = bufnr })
    vim.keymap.set('i', '<c-k>', vim.lsp.buf.signature_help, { buffer = bufnr })
    vim.keymap.set('n', '1gD', vim.lsp.buf.type_definition, { buffer = bufnr })
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = bufnr })
    vim.keymap.set('n', '<f2>', vim.lsp.buf.rename, { buffer = bufnr })
    vim.keymap.set('n', 'ga', vim.lsp.buf.code_action, { buffer = bufnr })
    vim.keymap.set('n', 'gq', format_range_operator, { buffer = bufnr })

    illuminate.on_attach(client)
    vim.keymap.set('n', '<a-n>', function() illuminate.next_reference { wrap = true } end, {buffer = bufnr })
    vim.keymap.set('n', '<a-p>', function() illuminate.next_reference { reverse = true, wrap = true } end, {buffer = bufnr })

    -- local augroup = vim.api.nvim_create_augroup('lsp_custom', {})
    -- vim.api.nvim_create_autocmd('CursorHold', {
    --     group = augroup,
    --     buffer = bufnr,
    --     callback = show_diagnostics,
    -- })
end

-- change diagnostic signs shown in sign column
vim.fn.sign_define("DiagnosticSignError", { text = '', texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = '', texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = '', texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = '', texthl = "DiagnosticSignHint" })

-- setup language servers
local servers = {
    pyright = {
        settings = {
            pyright = {
                autoImportCompletion = true,
            },
            python = {
                analysis = {
                    autoSearchPaths = true,
                    diagnosticMode = 'openFilesOnly',
                    useLibraryCodeForTypes = true,
                    typeCheckingMode = 'off'
                }
            }
        }
    },
    ruff = {},
    html = {'html-lsp'},
    cssls = {'css-lsp'},
    ts_ls = {'typescript-language-server'},
    biome = {},
    tinymist = {},
    jsonls = {'json-lsp'},
    gopls = {},
    lua_ls = {
        'lua-language-server',
        on_init = function(client)
            local path = client.workspace_folders[1].name
            ---@diagnostic disable-next-line: undefined-field
            if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
                return
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
                    -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                    -- library = vim.api.nvim_get_runtime_file("", true)
                }
            })
        end,
        settings = {
            Lua = {}
        }
    },
}

local lspconfig = require 'lspconfig'
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
        lspconfig[name].setup(vim.tbl_extend('keep', opts, {
            capabilities = capabilities,
            on_attach = on_attach,
            flags = {
                debounce_text_changes = 150
            }
        }))
        is_installed[mason_name] = false  -- to check which is not set up below
    end
end

for name, inst in pairs(is_installed) do
    if inst then
        print('LSP server', name, 'can be removed')
    end
end
