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
            message_lines[1] = ((diagnostic.source .. ': ') or '• ') .. message_lines[1]
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
        -- vim.api.nvim_set_var('reS', vim.inspect(result))
        if not result or not result.signatures or vim.tbl_isempty(result.signatures) or not result.activeSignature or not result.signatures[result.activeSignature + 1].parameters then
            return floating_win(sig_win)  -- close
        end
        local param = result.signatures[result.activeSignature + 1].parameters[(result.activeParameter or 0) + 1]
        if not param then return end
        local text = param.label
        if param.documentation ~= nil and param.documentation ~= vim.NIL then
            -- vim.api.nvim_set_var('DoC', vim.inspect(param.documentation))
            if type(param.documentation) == 'table' then
                param.documentation = param.documentation.value
            end
            text = text .. ': ' .. param.documentation
        end
        local lines = {}
        for line in text:gmatch("([^\n]*)\n?") do
            table.insert(lines, line)
        end
        last_row = -#lines
        local opts = vim.tbl_extend('force', floating_win_opts, {width = #text + 2, col = sig_col, row = last_row})
        sig_win = floating_win(sig_win, sig_buf, lines, opts)
    end)
end

---------------- COMPLETION HELP --------------------

local compl_buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_option(compl_buf, 'undolevels', -1)
local compl_win = 2

function completion_help()
    local info = vim.api.nvim_get_vvar('event')
    local item = info.completed_item
    if not item or not item.info or #item.info < 2 then
        return floating_win(compl_win)  -- close
    end
    vim.api.nvim_set_var('infO', vim.inspect(info))
    local lines = vim.split(item.info, '\n')
    local col = info.col[false] + info.width[false]
    local width = 0
    for i, line in pairs(lines) do width = math.max(width, #line + 2) end -- 2 is for the side spaces
    width = math.min(width, vim.api.nvim_get_option('columns') - col)
    if width < 5 then return end
    local height = 0
    for _, line in ipairs(lines) do
        local displaywidth = vim.fn.strdisplaywidth(line) + 1
        height = height + math.ceil(displaywidth / width)
    end
    height = math.min(height, vim.api.nvim_get_option('lines') - info.row[false] - 1)
    local opts = {relative = 'editor', row = info.row[false], col = col, height = height, width = width, style = 'minimal'}
    vim.loop.new_timer():start(0, 0, vim.schedule_wrap(function()
        compl_win = floating_win(compl_win, compl_buf, lines, opts)
    end))
end

------------------ COMPLETION ----------------------

local chars = 2 -- chars before triggering
local triggers = {lua = ':\\|\\.'} -- trigger patterns
local keys = {
    nxt = '\14',  -- <c-n>
    prev = '\16',  -- <c-p>
    omni = '\24\15',  -- <c-x><c-o>
    default = '\t'  -- <tab>, default key for mapping
}

-- go through suggestions or jump to snippet placeholders
-- if direction == 0 autocomplete, usable in autocmd TextChangedI
-- if direction == -1 or 1 usable in a mapping with <tab> and <s-tab>
--    if pumvisible
--        direction == -1 backward
--        direction == 1 forward
--    else force show completion
function complete(direction)
    if vim.fn.pumvisible() == 1 then
        if direction == 1 then return keys.nxt
        elseif direction == -1 then return keys.prev end
    end
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line_to_cursor = vim.api.nvim_get_current_line():sub(1, col)
    local current_keyword_start_col = vim.regex('\\k*$'):match_str(line_to_cursor) + 1
    local prefix = line_to_cursor:sub(current_keyword_start_col)
    -- trigger. default: most languages use a dot for class.property
    local trigger = triggers[vim.api.nvim_buf_get_option(0, 'filetype')] or '\\.'
    if not vim.regex(trigger):match_str(line_to_cursor:sub(-1)) then  -- not at trigger
        if not direction and #prefix ~= chars or direction and prefix == '' then
            return keys.default  -- no possible suggestions or prevent useless refresh
        end
        -- local omnifunc = vim.api.nvim_buf_get_option(0, 'omnifunc')
        -- if #omnifunc > 0 and omnifunc ~= 'v:lua.vim.lsp.omnifunc' then
        --     vim.fn.feedkeys(keys.omni)
        -- end
        -- if vim.fn.pumvisible() == 0 then vim.fn.feedkeys(keys.nxt) end
        vim.fn.feedkeys(keys.nxt)
    end
    if not vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
        -- request standard lsp completion (taken from nvim core lsp code)
        vim.lsp.buf_request(0, 'textDocument/completion', vim.lsp.util.make_position_params(), function(err, _, result)
            vim.api.nvim_set_var('ReS', vim.inspect(result))
            local in_insert_mode = vim.tbl_contains({'i', 'ic'}, vim.api.nvim_get_mode().mode)
            if err or not result or not in_insert_mode or vim.tbl_isempty(result) then return end
            local matches = vim.lsp.util.text_document_completion_list_to_complete_items(result, prefix)
            vim.list_extend(matches, vim.fn.complete_info().items)
            vim.fn.complete(current_keyword_start_col, matches)
        end)
    end
    return ''
end

-------------------- SETUP ------------------------

-- completion
local map_opts = {noremap=true, silent=true}
local imap_opts = vim.tbl_extend('keep', map_opts, {expr = true})
vim.api.nvim_set_keymap('i', '<tab>', 'v:lua.complete(1)', imap_opts)
vim.api.nvim_set_keymap('i', '<s-tab>', 'v:lua.complete(-1)', imap_opts)
vim.api.nvim_set_keymap('s', '<tab>', 'v:lua.complete(1)', imap_opts)
vim.api.nvim_command [[autocmd TextChangedI * lua complete()]]

-- setup func
local function on_attach(client, bufnr)
    -- completion help
    vim.api.nvim_command [[autocmd CompleteChanged,CompleteDone <buffer> lua completion_help()]]
    -- -- diagnostics
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
    map(bufnr, 'n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<cr>',      map_opts)
end

-- setup language servers
local servers = {
    pyright = {cmd = {"pyright-langserver.cmd", "--stdio"}},
    texlab = {},
    html = {cmd = {"html-languageserver.cmd", "--stdio"}},
    cssls = {cmd = {"css-languageserver.cmd", "--stdio"}},
    tsserver = {cmd = {"typescript-language-server.cmd", "--stdio"}},
    gopls = {},
    intelephense = {cmd = { "intelephense.cmd", "--stdio" }}
}
local lspconfig = require 'lspconfig'
for name, opts in pairs(servers) do
    lspconfig[name].setup(vim.tbl_extend('keep', opts, {on_attach=on_attach}))
end
