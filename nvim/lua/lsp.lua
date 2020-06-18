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


-- for complete()
local triggers = {lua = ':'} -- trigger pattern
local chars = 2 -- chars before triggering
local util = require 'vim.lsp.util'
local lsp = require 'vim.lsp'
function complete(direction)  -- completion function
    -- try chain: omnifunc -> keyword
    if vim.fn.pumvisible() == 1 then
        if direction == 1 then return ""  -- "<c-n>"
        elseif direction == -1 then return "" end  -- "<c-p>"
    end
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line_to_cursor = vim.api.nvim_get_current_line():sub(1, col)
    local current_keyword_start = vim.regex('\\k*$'):match_str(line_to_cursor) + 1
    local prefix = line_to_cursor:sub(current_keyword_start)
    -- nearest character is a trigger
    local trigger = triggers[vim.api.nvim_buf_get_option(0, 'filetype')]
    if not trigger then trigger = "\\." end  -- most languages use a dot for class.property
    local at_trigger = vim.regex(trigger):match_str(line_to_cursor:sub(-1))
    if not at_trigger and (direction == 0 and (prefix:len() ~= chars or prefix == '') or direction ~= 0 and prefix == '') then
        return "	"  -- no possible suggestions or prevent useless refresh
    end
    local omnifunc = vim.api.nvim_buf_get_option(0, 'omnifunc')
    if omnifunc == 'v:lua.vim.lsp.omnifunc' then
        -- perform standard lsp completion request (taken from nvim core code)
        lsp.buf_request(0, 'textDocument/completion', util.make_position_params(), function(err, _, result)
            if err or not result or vim.api.nvim_get_mode().mode ~= "i" then return end
            local matches = util.text_document_completion_list_to_complete_items(result, prefix)
            if vim.tbl_isempty(matches) then
                vim.api.nvim_input("<c-n>")  -- keyword completion
            else
                vim.fn.complete(current_keyword_start, matches)
            end
        end)
    elseif omnifunc:len() > 0 then
        vim.api.nvim_input("<c-x><c-o>")
        if not vim.fn.pumvisible() then
            vim.api.nvim_input("<c-n>")  -- keyword completion
        end
    else
        vim.api.nvim_input("<c-n>")  -- keyword completion
    end
    return ''
end
