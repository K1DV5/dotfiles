-- disable disgnostics for current line in insert mode:
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

local map = vim.api.nvim_buf_set_keymap

-- setup func
local function on_attach(_, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    vim.api.nvim_command [[autocmd InsertEnter <buffer> lua publish_diagnostics(false)]]
    vim.api.nvim_command [[autocmd InsertLeave <buffer> lua publish_diagnostics(true)]]
    -- vim.api.nvim_command [[autocmd CompleteChanged <buffer> lua completion_help()]]
    -- Mappings
    local opts = {noremap=true, silent=true}
    map(bufnr, 'n', '<c-]>',      '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    map(bufnr, 'n',  'gd',        '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    map(bufnr, 'n',  'K',         '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    map(bufnr, 'n',  'gD',        '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    map(bufnr, 'n',  '<c-k>',     '<cmd>lua signature_help()<CR>', opts)
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


-- customize completion
local chars = 2 -- chars before triggering
local triggers = {lua = ':\\|\\.'} -- trigger patterns
local keys = {
    next = '\14',  -- <c-n>
    prev = '\16',  -- <c-p>
    tab = '\t',  -- <tab>
    omni = '\24\15'  -- <c-x><c-o>
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
        if direction == 0 and prefix:len() ~= chars or direction ~= 0 and prefix == '' then
            return keys.tab  -- no possible suggestions or prevent useless refresh
        end
        local omnifunc = vim.api.nvim_buf_get_option(0, 'omnifunc')
        if omnifunc:len() > 0 and omnifunc ~= 'v:lua.vim.lsp.omnifunc' then
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

-- local compl_buf = vim.api.nvim_create_buf(false, true), compl_win
-- local opts = {relative = 'cursor', width = 50, height = 20, row = 1, style = 'minimal'}

-- function completion_help()
--     local item = vim.api.nvim_get_vvar('event').completed_item
--     if vim.fn.pumvisible() == 0 or not item or not item.info or item.info == '' then
--         if compl_win then
--             vim.api.nvim_win_close(compl_win, true)
--             compl_win = nil
--         end
--         return
--     end
--     local filetype = vim.api.nvim_buf_get_option(0, 'filetype')
--     vim.api.nvim_buf_set_option(compl_buf, 'filetype', filetype)
--     -- vim.fn.append(0, vim.split(item.info, '\n'))
--     vim.api.nvim_buf_set_lines(compl_buf, 0, -1, true, vim.split(item.info, '\n'))
--     local opts = vim.tbl_extend('force', opts, {col = vim.fn.pum_getpos().width})
--     if compl_win then
--         vim.api.nvim_win_set_config(compl_win, opts)
--     else
--         compl_win = vim.api.nvim_open_win(compl_buf, false, opts)
--     end
--     -- vim.api.nvim_set_var('iteM', vim.inspect(item))
-- end

function signature_help()
    vim.lsp.buf_request(0, 'textDocument/hover', vim.lsp.util.make_position_params(), function(err, _, result)
        local sig = result.contents[1]
        if not sig then return print('No signature') end
        vim.lsp.util.open_floating_preview({sig.value}, sig.language)
    end)
end

