-- K1DV5's custom lsp config

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

local map_opts = {noremap=true, silent=true}

-- range formatting
function format_range_operator()
    local has_range = false
    for _, server in ipairs(vim.lsp.buf_get_clients(0)) do
        if server.server_capabilities.documentRangeFormattingProvider == true then
            has_range = true
        end
    end
    if not has_range then
        vim.lsp.buf.formatting()
        return
    end
    local old_func = vim.go.operatorfunc
    _G.op_func_formatting = function()
        local start = vim.api.nvim_buf_get_mark(0, '[')
        local finish = vim.api.nvim_buf_get_mark(0, ']')
        vim.lsp.buf.range_formatting({}, start, finish)
        vim.go.operatorfunc = old_func
        _G.op_func_formatting = nil
    end
    vim.o.operatorfunc = 'v:lua.op_func_formatting'
    vim.api.nvim_feedkeys('g@', 'n', false)
end

local illuminate = require'illuminate'
-- setup func
local function on_attach(client, bufnr)
    -- diagnostics
    vim.api.nvim_command [[autocmd CursorHold <buffer> lua vim.diagnostic.open_float({focusable = false, scope = 'cursor'})]]
    -- Mappings
    local map = vim.api.nvim_buf_set_keymap
    map(bufnr, 'n', '<c-]>',     '<cmd>lua vim.lsp.buf.declaration()<CR>',     map_opts)
    map(bufnr, 'n', 'gd',        '<cmd>lua vim.lsp.buf.definition()<CR>',      map_opts)
    map(bufnr, 'n', 'K',         '<cmd>lua vim.lsp.buf.hover()<CR>',           map_opts)
    map(bufnr, 'n', 'gD',        '<cmd>lua vim.lsp.buf.implementation()<CR>',  map_opts)
    map(bufnr, 'i', '<c-k>',     '<cmd>lua vim.lsp.buf.signature_help()<CR>',  map_opts)
    map(bufnr, 'n', '1gD',       '<cmd>lua vim.lsp.buf.type_definition()<CR>', map_opts)
    map(bufnr, 'n', 'gr',        '<cmd>lua vim.lsp.buf.references()<CR>',      map_opts)
    map(bufnr, 'n', '<f2>',      '<cmd>lua vim.lsp.buf.rename()<CR>',          map_opts)
    map(bufnr, 'n', 'ga',        '<cmd>lua vim.lsp.buf.code_action()<CR>',     map_opts)
    map(bufnr, 'n', 'gq',        '<cmd>lua format_range_operator()<cr>',       map_opts)
    illuminate.on_attach(client)
    vim.api.nvim_set_keymap('n', '<a-n>', '<cmd>lua require"illuminate".next_reference{wrap=true}<cr>', map_opts)
    vim.api.nvim_set_keymap('n', '<a-p>', '<cmd>lua require"illuminate".next_reference{reverse=true,wrap=true}<cr>', map_opts)
end

-- change diagnostic signs shown in sign column
vim.fn.sign_define("DiagnosticSignError", {text = '', texthl = "DiagnosticSignError"})
vim.fn.sign_define("DiagnosticSignWarn", {text = '', texthl = "DiagnosticSignWarn"})
vim.fn.sign_define("DiagnosticSignInfo", {text = '', texthl = "DiagnosticSignInfo"})
vim.fn.sign_define("DiagnosticSignHint", {text = '', texthl = "DiagnosticSignHint"})

-- enable snippets support on client
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- setup language servers
local servers = {
    pyright = {},
    -- texlab = {},
    html = {},
    cssls = {},
    jsonls = {
        commands = {
            Format = {
                function()
                    vim.lsp.buf.range_formatting({}, {0, 0}, {vim.fn.line("$"), 0})
                end
            }
        }
    },
    tsserver = {},
    gopls = {},
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
