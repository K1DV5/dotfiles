-- custom lsp config

-------------------------------------------------
-- this is to be used to work with floating wins
-- by custom functions below.
local floating_win_opts = {relative = 'cursor', row = -1, col = 0, style = 'minimal'}
local function floating_win(win, buf, lines, opts)
    if not buf then
        if vim.api.nvim_win_is_valid(win) then
            pcall(vim.api.nvim_win_close, win, true)
        end
        return
    end
    local opts_new = {width = opts.width, height = opts.height}
    if lines then
        for i, line in ipairs(lines) do
            if #line > 0 then lines[i] = ' ' .. line .. ' ' end
        end
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
        if not opts_new.width then
            opts_new.width = 1
            for _, line in ipairs(lines) do
                opts_new.width = math.max(opts_new.width, #line)
            end
        end
        if not opts_new.height then opts_new.height = #lines end
    end
    opts_new = vim.tbl_extend('keep', opts_new, opts)
    if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_config(win, opts_new)
        return win
    end
    if lines then
        return vim.api.nvim_open_win(buf, false, opts_new)
    end
    return win
end

------------------ DIAGNOSTICS ----------------------

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false,
        update_in_insert = false,
    }
)

-------------------- SETUP ------------------------

-- range formatting
local function format_range_operator()
    local has_range = false
    for _, server in ipairs(vim.lsp.buf_get_clients(0)) do
        if server.server_capabilities.documentRangeFormattingProvider == true then
            has_range = true
        end
    end
    if not has_range then
        vim.lsp.buf.format{async = true}
        return
    end
    local old_func = vim.go.operatorfunc
    _G.op_func_format = function()
        local start = vim.api.nvim_buf_get_mark(0, '[')
        local finish = vim.api.nvim_buf_get_mark(0, ']')
        vim.lsp.buf.format{async = true, range = {start = start, ["end"] = finish}}
        vim.go.operatorfunc = old_func
        _G.op_func_format = nil
    end
    vim.o.operatorfunc = 'v:lua.op_func_format'
    vim.api.nvim_feedkeys('g@', 'n', false)
end

local illuminate = require'illuminate'
-- setup func
local function on_attach(client, bufnr)
    -- diagnostics
    vim.api.nvim_create_autocmd('CursorHold', {
        group = augroup,
        buffer = bufnr,
        callback = function() vim.diagnostic.open_float({focusable = false, scope = 'cursor'}) end,
    })
    -- Mappings
    local map = vim.api.nvim_buf_set_keymap
    vim.keymap.set('n', '<c-]>', vim.lsp.buf.declaration,     { buffer = bufnr })
    vim.keymap.set('n', 'gd',    vim.lsp.buf.definition,      { buffer = bufnr })
    vim.keymap.set('n', 'K',     vim.lsp.buf.hover,           { buffer = bufnr })
    vim.keymap.set('n', 'gD',    vim.lsp.buf.implementation,  { buffer = bufnr })
    vim.keymap.set('i', '<c-k>', vim.lsp.buf.signature_help,  { buffer = bufnr })
    vim.keymap.set('n', '1gD',   vim.lsp.buf.type_definition, { buffer = bufnr })
    vim.keymap.set('n', 'gr',    vim.lsp.buf.references,      { buffer = bufnr })
    vim.keymap.set('n', '<f2>',  vim.lsp.buf.rename,          { buffer = bufnr })
    vim.keymap.set('n', 'ga',    vim.lsp.buf.code_action,     { buffer = bufnr })
    vim.keymap.set('n', 'gq',    format_range_operator,       { buffer = bufnr })
    illuminate.on_attach(client)
    vim.keymap.set('n', '<a-n>', function() illuminate.next_reference{wrap=true} end)
    vim.keymap.set('n', '<a-p>', function() illuminate.next_reference{reverse=true,wrap=true} end)
end

-- change diagnostic signs shown in sign column
vim.fn.sign_define("DiagnosticSignError", {text = '', texthl = "DiagnosticSignError"})
vim.fn.sign_define("DiagnosticSignWarn", {text = '', texthl = "DiagnosticSignWarn"})
vim.fn.sign_define("DiagnosticSignInfo", {text = '', texthl = "DiagnosticSignInfo"})
vim.fn.sign_define("DiagnosticSignHint", {text = '', texthl = "DiagnosticSignHint"})

-- enable snippets support on client
local capabilities = require('cmp_nvim_lsp').default_capabilities()

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
    -- texlab = {},
    html = {},
    cssls = {},
    jsonls = {},
    tsserver = {},
    gopls = {},
    eslint = {},
    ruff_lsp = {},
}

local lspconfig = require 'lspconfig'
for name, opts in pairs(servers) do
    lspconfig[name].setup(vim.tbl_extend('keep', opts, {
        capabilities = capabilities,
        on_attach = on_attach,
        flags = {
            debounce_text_changes = 150
        }
    }))
end
