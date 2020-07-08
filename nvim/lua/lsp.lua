------------------ DIAGNOSTICS ----------------------
local default_diagnostic_callback = vim.lsp.callbacks["textDocument/publishDiagnostics"]
local err, method, params, client_id

function publish_diagnostics(normal_mode)
    if normal_mode then
        return default_diagnostic_callback(err, method, params, client_id)
    end
    -- insert mode
    if not params then return end
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    local pms = {diagnostics = {}, uri = params.uri}
    for _, diag in pairs(params.diagnostics) do
        if diag.range.start.line ~= line then
            table.insert(pms.diagnostics, diag)
        end
    end
    default_diagnostic_callback(err, method, pms, client_id)
end

vim.lsp.callbacks["textDocument/publishDiagnostics"] = function(...)
    err, method, params, client_id = ...
    local normal_mode = vim.api.nvim_get_mode().mode == 'n'
    publish_diagnostics(normal_mode)
end

---------------- SIGNATURE PARAMS HELP ----------------------
-- to be used with completion

local function floating_win(buf, win, text, opts)
    if not buf then
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
        return
    end
    if text then
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, text)
    end
    if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_config(win, opts)
        return win
    end
    if text then
        return vim.api.nvim_open_win(buf, false, opts)
    end
    return win
end

local opts = {relative = 'cursor', row = -1, height = 1, style = 'minimal'}
local sig_buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_option(sig_buf, 'undolevels', -1)
vim.api.nvim_buf_set_option(sig_buf, 'filetype', 'coco')
local sig_win = 1
local last_col = 0

function signature_help(show)
    if not show then return floating_win(nil, sig_win, nil, nil) end  -- close
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line_to_cursor = vim.api.nvim_get_current_line():sub(1, col)
    local kw_start = string.find(line_to_cursor, '[a-zA-Z0-9_]+$')
    local sig_col = 0  -- signature help column
    if kw_start then
        if col > last_col then return floating_win(nil, sig_win, nil, nil) end  -- same signature, no change, close
        sig_col = kw_start - #line_to_cursor - 1
    elseif string.find(line_to_cursor, '[ \t]$') then
        local opts = {relative = 'cursor', row = -1, col = sig_col}
        return floating_win(sig_buf, sig_win, nil, opts)  -- move
    end
    last_col = col
    vim.lsp.buf_request(0, 'textDocument/signatureHelp', vim.lsp.util.make_position_params(), function(err, _, result)
        vim.api.nvim_set_var('reS', vim.inspect(result))
        if err or not result or not result.signatures or vim.tbl_isempty(result.signatures) then
            return floating_win(nil, sig_win, nil, nil)  -- close
        end
        local param = result.signatures[result.activeSignature + 1].parameters[(result.activeParameter or 0) + 1]
        local text = param.label
        if param.documentation ~= nil and param.documentation ~= vim.NIL then
            text = text .. ': ' .. param.documentation
        end
        local opts = vim.tbl_extend('force', opts, {width = #text + 2, col = sig_col})
        sig_win = floating_win(sig_buf, sig_win, {' ' .. text .. ' '}, opts)
    end)
end

---------------- COMPLETION HELP --------------------

local compl_buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_option(compl_buf, 'filetype', 'markdown')
vim.api.nvim_buf_set_option(compl_buf, 'undolevels', -1)
local compl_win = 2

function completion_help()
    local info = vim.api.nvim_get_vvar('event')
    local item = info.completed_item
    if not item or not item.info or item.info == '' then
        return floating_win(nil, compl_win, nil, nil)  -- close
    end
    local lines = vim.split(item.info, '\n')
    local selected = vim.fn.complete_info().selected
    local row
    if selected > -1 then row = info.row + selected else row = info.row end
    local col = info.col + info.width
    local width = 0
    for i, line in pairs(lines) do
        width = math.max(width, #line)
        if #line > 0 then lines[i] = ' ' .. line .. ' ' end
    end
    width = math.min(width, vim.api.nvim_get_option('columns') - col)
    local height = math.min(#lines, vim.api.nvim_get_option('lines') - row - 1)
    local opts = {relative = 'editor', row = row, col = col, height = height, width = width, style = 'minimal'}
    -- vim.api.nvim_set_var('iteM', vim.inspect(item))
    vim.loop.new_timer():start(0, 0, vim.schedule_wrap(function()
        compl_win = floating_win(compl_buf, compl_win, lines, opts)
        vim.api.nvim_win_set_option(compl_win, 'wrap', false)
    end))
end

------------------ COMPLETION ----------------------

local chars = 2 -- chars before triggering
local triggers = {lua = ':\\|\\.'} -- trigger patterns
local keys = {
    next = '\14',  -- <c-n>
    prev = '\16',  -- <c-p>
    omni = '\24\15',  -- <c-x><c-o>
    default = '\t'  -- <tab>, default key for mapping
}

-- completion function
-- if direction == 0 autocomplete, usable in autocmd TextChangedI
-- if direction == -1 or 1 usable in a mapping with <tab> and <s-tab>
--    if pumvisible
--        direction == -1 backward
--        direction == 1 forward
--    else force show completion
-- try lsp then chain_complete()
function complete(direction)
    if vim.fn.pumvisible() == 1 then
        if direction == 1 then return keys.next
        elseif direction == -1 then return keys.prev end
    end
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line_to_cursor = vim.api.nvim_get_current_line():sub(1, col)
    local current_keyword_start_col = vim.regex('\\k*$'):match_str(line_to_cursor) + 1
    local prefix = line_to_cursor:sub(current_keyword_start_col)
    -- trigger. default: most languages use a dot for class.property
    local trigger = triggers[vim.api.nvim_buf_get_option(0, 'filetype')] or '\\.'
    if not vim.regex(trigger):match_str(line_to_cursor:sub(-1)) then  -- not at trigger
        if direction == 0 and #prefix ~= chars or direction ~= 0 and prefix == '' then
            return keys.default  -- no possible suggestions or prevent useless refresh
        end
        local omnifunc = vim.api.nvim_buf_get_option(0, 'omnifunc')
        if #omnifunc > 0 and omnifunc ~= 'v:lua.vim.lsp.omnifunc' then
            vim.fn.feedkeys(keys.omni)
        end
        if vim.fn.pumvisible() == 0 then vim.fn.feedkeys(keys.next) end
    end
    if not vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
        -- request standard lsp completion (taken from nvim core lsp code)
        vim.lsp.buf_request(0, 'textDocument/completion', vim.lsp.util.make_position_params(), function(err, _, result)
            if err or not result or vim.api.nvim_get_mode().mode == 'n' or vim.tbl_isempty(result) then return end
            local matches = vim.lsp.util.text_document_completion_list_to_complete_items(result, prefix)
            vim.list_extend(matches, vim.fn.complete_info().items)
            vim.fn.complete(current_keyword_start_col, matches)
        end)
    end
    return ''
end

-------------------- SETUP ------------------------
local map = vim.api.nvim_buf_set_keymap

-- setup func
local function on_attach(_, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    vim.api.nvim_command [[autocmd InsertEnter <buffer> lua publish_diagnostics(false); signature_help(true)]]
    vim.api.nvim_command [[autocmd InsertLeave <buffer> lua publish_diagnostics(true); signature_help(false)]]
    vim.api.nvim_command [[autocmd CompleteChanged,CompleteDone <buffer> lua completion_help()]]
    vim.api.nvim_command [[autocmd TextChangedI <buffer> lua signature_help(true)]]
    -- Mappings
    local opts = {noremap=true, silent=true}
    map(bufnr, 'n', '<c-]>',      '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    map(bufnr, 'n',  'gd',        '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    map(bufnr, 'n',  'K',         '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    map(bufnr, 'n',  'gD',        '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    map(bufnr, 'i',  '<c-k>',     '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    map(bufnr, 'n',  '1gD',       '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    map(bufnr, 'n',  'gr',        '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    map(bufnr, 'n',  '<f2>',      '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    map(bufnr, 'n',  '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<cr>', opts)
end

-- setup pyls, texlab, html, tsserver
local nvim_lsp = require('nvim_lsp')
for _, lsp in ipairs({'pyls', 'texlab'}) do
    nvim_lsp[lsp].setup{on_attach=on_attach}
end
nvim_lsp.html.setup{filetypes = {'html', 'svelte'}; cmd = {'html-languageserver.cmd', '--stdio'}, on_attach=on_attach}
nvim_lsp.tsserver.setup{cmd = {'typescript-language-server.cmd', '--stdio'}, on_attach=on_attach}
