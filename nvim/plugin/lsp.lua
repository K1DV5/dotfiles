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

-- for floating_line_diagnostics()
local floating_diag_severity_hi = {}
for name, value in pairs(require('vim.lsp.protocol').DiagnosticSeverity) do
    floating_diag_severity_hi[value] = 'LspDiagnosticsVirtualText' .. name
end
local diag_buf = vim.api.nvim_create_buf(false, true)
local diag_win = 1
vim.api.nvim_buf_set_option(diag_buf, 'undolevels', -1)

-- show diagnostics for current line in a floating_win
function floating_line_diagnostics(show)
    if not show then return floating_win(diag_win) end  -- close
    local pos = vim.api.nvim_win_get_cursor(0)
    local line, col = pos[1] - 1, pos[2]
    local diags = vim.lsp.diagnostic.get_line_diagnostics()
    -- vim.api.nvim_set_var('diaG', vim.inspect(diags))
    local lines, highlights = {}, {}
    for i, diagnostic in ipairs(diags) do
        local End = diagnostic.range['end']
        if End.line > line or diagnostic.range.start.character <= col and End.character >= col then
            local hiname = floating_diag_severity_hi[diagnostic.severity]
            local message_lines = vim.split(diagnostic.message, '\n')
            message_lines[1] = (diagnostic.source and (diagnostic.source .. ': ') or '• ') .. message_lines[1]
            for _, line in ipairs(message_lines) do
                table.insert(lines, line)
                table.insert(highlights, hiname)
            end
        end
    end
    if #lines == 0 then return floating_win(diag_win) end
    local new_opts
    if #lines > line then new_opts = {anchor = 'NW', row = 1}
    else new_opts = {anchor = 'SW', row = 0} end
    diag_win = floating_win(diag_win, diag_buf, lines, vim.tbl_extend('keep', new_opts, floating_win_opts))
    for i, hi in ipairs(highlights) do
        vim.api.nvim_buf_add_highlight(diag_buf, -1, hi, i-1, 0, -1)
    end
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false,
        update_in_insert = false,
    }
)


------------------ SIGNATURE PARAMS HELP ----------------------
---- to be used with completion

local sig_buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_option(sig_buf, 'undolevels', -1)
vim.api.nvim_buf_set_option(sig_buf, 'filetype', 'coco')
local sig_win = 1
local last_col = 0
local last_row = -1

function signature_help(show)
    if not show then return floating_win(sig_win) end  -- close
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line_to_cursor = vim.api.nvim_get_current_line():sub(1, col)
    local kw_start = string.find(line_to_cursor, '[a-zA-Z0-9_]+$')
    local sig_col = 0  -- signature help column
    if kw_start then
        if col > last_col then return floating_win(sig_win) end  -- same signature, no change, close
        sig_col = kw_start - #line_to_cursor - 1
    elseif string.find(line_to_cursor, '[ \t]$') then
        local opts = {relative = 'cursor', row = last_row, col = sig_col}
        return floating_win(sig_win, sig_buf, nil, opts)  -- move
    end
    last_col = col
    vim.lsp.buf_request(0, 'textDocument/signatureHelp', vim.lsp.util.make_position_params(), function(err, _, result)
        if not result or not result.signatures or vim.tbl_isempty(result.signatures) or not result.activeSignature or not result.signatures[result.activeSignature + 1].parameters then
            return floating_win(sig_win)  -- close
        end
        local sig = result.signatures[result.activeSignature + 1] 
        local param = sig.parameters[(sig.activeParameter or result.activeParameter or 0) + 1]
        if not param then return end
        local text = param.label
        if type(param.label) == 'table' then
            text = sig.label:sub(param.label[1] + 1, param.label[2])
        end
        if param.documentation ~= nil and param.documentation ~= vim.NIL then
            -- vim.api.nvim_set_var('DoC', vim.inspect(param.documentation))
            if type(param.documentation) == 'table' then
                param.documentation = param.documentation.value
            end
            text = text .. ': ' .. param.documentation
        end
        local lines = text:split("\n")
        last_row = -#lines
        local opts = vim.tbl_extend('force', floating_win_opts, {width = #text + 2, col = sig_col, row = last_row})
        sig_win = floating_win(sig_win, sig_buf, lines, opts)
    end)
end

-------------------- SETUP ------------------------

-- completion
local keys = {
    nxt = '\14',  -- <c-n>
    prev = '\16',  -- <c-p>
    omni = '\24\15',  -- <c-x><c-o>
    default = '\t'  -- <tab>, default key for mapping
}

local function check_back_space()
  local col = vim.fn.col '.' - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' ~= nil
end

local cmp = require'cmp'
function complete(direction)
    if vim.fn.pumvisible() == 0 then
        if check_back_space() then return keys.default
        else cmp.mapping.complete() end
    end
    if direction == 1 then return keys.nxt
    elseif direction == -1 then return keys.prev end
end

-- completion
local map_opts = {noremap=true, silent=true}
local imap_opts = vim.tbl_extend('keep', map_opts, {expr = true})
vim.api.nvim_set_keymap('i', '<tab>', 'v:lua.complete(1)', imap_opts)
vim.api.nvim_set_keymap('i', '<s-tab>', 'v:lua.complete(-1)', imap_opts)
vim.api.nvim_set_keymap('s', '<tab>', 'v:lua.complete(1)', imap_opts)

-- setup func
local function on_attach(client, bufnr)
    -- diagnostics
    -- vim.api.nvim_command [[autocmd InsertEnter <buffer> lua publish_diagnostics(0, nil, false); floating_line_diagnostics(false)]]
    -- vim.api.nvim_command [[autocmd InsertLeave <buffer> lua publish_diagnostics(0, nil, true); floating_line_diagnostics(true)]]
    vim.api.nvim_command [[autocmd InsertEnter <buffer> lua floating_line_diagnostics(false)]]
    vim.api.nvim_command [[autocmd InsertLeave <buffer> lua floating_line_diagnostics(true)]]
    vim.api.nvim_command [[autocmd CursorHold <buffer> lua floating_line_diagnostics(true)]]
    vim.api.nvim_command [[autocmd BufLeave <buffer> lua floating_line_diagnostics(false)]]
    -- floating signature parameters help
    if client.server_capabilities.signatureHelpProvider then
        vim.api.nvim_command [[autocmd InsertEnter <buffer> lua signature_help(true)]]
        vim.api.nvim_command [[autocmd InsertLeave <buffer> lua signature_help(false)]]
        vim.api.nvim_command [[autocmd TextChangedI <buffer> lua signature_help(true)]]
    end
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
    -- map(bufnr, 'n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<cr>',      map_opts)
end

-- enable snippets support on client
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- setup language servers
local servers = {
    pyright = {cmd = {"pyright-langserver.cmd", "--stdio"}},
    texlab = {},
    html = {
        cmd = {"vscode-html-language-server.cmd", "--stdio"},
        capabilities = capabilities
    },
    cssls = {
        cmd = {"vscode-css-language-server.cmd", "--stdio"},
        capabilities = capabilities
    },
    jsonls = {
        capabilities = capabilities,
        cmd = {"vscode-json-language-server.cmd", "--stdio"},
        commands = {
            Format = {
                function()
                    vim.lsp.buf.range_formatting({}, {0, 0}, {vim.fn.line("$"), 0})
                end
            }
        }
    },
    tsserver = {cmd = {"typescript-language-server.cmd", "--stdio"}},
    gopls = {},
}

local lspconfig = require 'lspconfig'
for name, opts in pairs(servers) do
    lspconfig[name].setup(vim.tbl_extend('keep', opts, {
        on_attach = on_attach,
        flags = {
            debounce_text_changes = 150
        }
    }))
end
