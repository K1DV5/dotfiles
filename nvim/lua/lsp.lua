-- disable disgnostics in insert mode:
local default_callback = vim.lsp.callbacks["textDocument/publishDiagnostics"]
local err, method, params, client_id

vim.lsp.callbacks["textDocument/publishDiagnostics"] = function(...)
    err, method, params, client_id = ...
    if ({i = 1; ic = 1})[vim.api.nvim_get_mode().mode] == nil then
        publish_diagnostics()
    end
end

function publish_diagnostics() default_callback(err, method, params, client_id) end

local map = vim.api.nvim_buf_set_keymap

local function on_attach(_, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    vim.api.nvim_command [[autocmd InsertLeave <buffer> lua publish_diagnostics()]]
    vim.api.nvim_command [[autocmd InsertEnter <buffer> call v:lua.vim.lsp.util.buf_clear_diagnostics(bufnr())]]
    -- Mappings
    local opts = {noremap=true, silent=true}
    map(bufnr, 'n', '<c-]>',      '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    map(bufnr, 'n',  'gd',        '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    map(bufnr, 'n',  'K',         '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    map(bufnr, 'n',  'gD',        '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    map(bufnr, 'n',  '<c-k>',     '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    map(bufnr, 'n',  '1gD',       '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    map(bufnr, 'n',  'gr',        '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    map(bufnr, 'n',  '<f2>',      '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    map(bufnr, 'n',  '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<cr>', opts)
end

-- pyls, texlab, html, tsserver
local nvim_lsp = require('nvim_lsp')
for _, lsp in ipairs({'pyls', 'texlab'}) do
    nvim_lsp[lsp].setup{on_attach=on_attach}
end
nvim_lsp.html.setup{filetypes = {'html', 'svelte'}; cmd = {'html-languageserver.cmd', '--stdio'}, on_attach=on_attach}
nvim_lsp.tsserver.setup{cmd = {'typescript-language-server.cmd', '--stdio'}, on_attach=on_attach}


local util = require 'vim.lsp.util'
local lsp = require 'vim.lsp'
-- for complete()
local chars = 2 -- chars before triggering
local keys = {
    next = '\14',  -- <c-n>
    prev = '\16',  -- <c-p>
    tab = '\t',  -- <tab>
    omni = '\24\15'  -- <c-x><c-o>
}
local triggers = {lua = ':\\|\\.'} -- trigger patterns
-- default trigger. most languages use a dot for class.property
setmetatable(triggers, {__index = function() return '\\.' end})

local function chain_complete()  -- try built in completions in sequence
    -- chain: omnifunc -> keyword
    local omnifunc = vim.api.nvim_buf_get_option(0, 'omnifunc')
    if omnifunc:len() > 0 and omnifunc ~= 'v:lua.vim.lsp.omnifunc' then
        vim.fn.feedkeys(keys.omni)
        if vim.fn.pumvisible() then return end
    end
    vim.fn.feedkeys(keys.next)
end

function complete(direction)  -- completion function
    -- if direction == 0 usable in autocmd TextChangedI
    -- if direction == -1 or 1 usable in a mapping with <tab> and <s-tab>
    --    if pumvisible
    --        direction == -1 backward
    --        direction == 1 forward
    --    else force show completion
    -- try lsp then chain_complete()
    if vim.fn.pumvisible() == 1 then
        if direction == 1 then return keys.next
        elseif direction == -1 then return keys.prev end
    end
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line_to_cursor = vim.api.nvim_get_current_line():sub(1, col)
    local current_keyword_start_col = vim.regex('\\k*$'):match_str(line_to_cursor) + 1
    local prefix = line_to_cursor:sub(current_keyword_start_col)
    local trigger = triggers[vim.api.nvim_buf_get_option(0, 'filetype')]
    local at_trigger = vim.regex(trigger):match_str(line_to_cursor:sub(-1))
    if not at_trigger and (direction == 0 and prefix:len() ~= chars or direction ~= 0 and prefix == '') then
        return keys.tab  -- no possible suggestions or prevent useless refresh
    end
    if not vim.tbl_isempty(lsp.buf_get_clients(0)) then
        -- request standard lsp completion (taken from nvim core lsp code)
        lsp.buf_request(0, 'textDocument/completion', util.make_position_params(), function(err, _, result)
            if err or vim.api.nvim_get_mode().mode ~= "i" then return end
            if not result or vim.tbl_isempty(result) then
                if not at_trigger then return chain_complete() end
                return
            end
            local matches = util.text_document_completion_list_to_complete_items(result, prefix)
            vim.fn.complete(current_keyword_start_col, matches)
        end)
    elseif not at_trigger then chain_complete() end
    return ''
end
