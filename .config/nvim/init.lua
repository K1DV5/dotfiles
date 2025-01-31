-- init script for neovim

local o = vim.opt
local g = vim.g

-- set mapleader, should be before lazy
g.mapleader = ','

-- system clipboard {{{
if os.getenv('WSL_DISTRO_NAME') ~= nil then
    vim.g.clipboard = {
        name = 'wsl clipboard',
        copy = { ["+"] = { "clip.exe" }, ["*"] = { "clip.exe" } },
        paste = { ["+"] = { "nvim_paste" }, ["*"] = { "nvim_paste" } },
        cache_enabled = true
    }
end

-- }}}

-- options {{{
-- miscellaneous {{{
-- continue wrapped lines with the same indent
o.breakindent = true
-- use four spaces for tabs
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
-- keep changes persistent after quitting
o.undofile = true
-- dont highlight matches from last search
o.hlsearch = false
-- auto change search to case sensitive when there are upper cases
o.smartcase = true
-- turn on line numbers where the cursor is (revert: set nonumber)
o.number = true
o.relativenumber = true
-- highlight current line
o.cursorline = true
-- enable true color on terminal
o.termguicolors = true
-- set the time to update misc things
o.updatetime = 100
-- disable swapfiles, allow editing outside nvim
o.swapfile = false
-- keep windows the same size when adding/removing
o.equalalways = false
-- hide the ~'s at the end of files and other chars
o.fillchars = { eob = ' ', diff = ' ', fold = ' ', stl = ' ' }
-- read options only from the first and last lines
o.modelines = 1
-- dont show the mode on command line
o.showmode = false
-- split to the right
o.splitright = true
-- only scan current and other windows for keyword completions
o.complete = '.,w,b,t'
-- dont be chatty on completions
o.shortmess:append('c')
-- show diff with vertical split
o.diffopt:append('vertical')
-- always have a space for signs
o.signcolumn = 'yes'
-- some filetype specific features
vim.cmd 'filetype plugin indent on'
-- default sql variant
g.sql_type_default = 'mysql'
-- disable the tabline
o.showtabline = 0
-- to show line numbers on <c-g>, disable on statusline
o.ruler = false
-- store buffers and cd accross sessions
o.ssop = 'buffers,curdir,localoptions'
-- use ripgrep
o.grepprg = 'rg'
-- allow mouse interaction
o.mouse = 'a'

-- }}}
-- performance {{{
-- disable builtins plugins
local disabled_built_ins = {
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "gzip",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "2html_plugin",
    "logipat",
    "rrhelper",
    "spellfile_plugin",
    "matchit"
}

for _, plugin in pairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
end
-- }}}
-- }}}

-- packages {{{

require 'packages'

local tabs = require 'tabs'
tabs.setup()
local term = require 'term'
term.setup()

require 'lsp'

-- }}}

-- functions {{{
local function exec_first_line_cmd()     -- {{{
    vim.cmd [[silent update!]]
    vim.cmd [[wincmd k]]
    local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ''
    if first_line == '' then
        return
    end
    local i_start_cmd = string.find(first_line, ' $', 1, true)
    if i_start_cmd == nil then
        return
    end
    i_start_cmd = i_start_cmd + 2         -- without the prompt
    if string.sub(first_line, i_start_cmd, i_start_cmd) == ' ' then
        i_start_cmd = i_start_cmd + 1     -- without the preceding space
    end
    local cmd = string.sub(first_line, i_start_cmd)
    cmd = string.gsub(cmd, '%%d', vim.fn.expand('%:h'))
    cmd = string.gsub(cmd, '%%f', vim.fn.expand('%:p'))
    cmd = string.gsub(cmd, '%%n', vim.fn.expand('%:t:r'))
    local dir = vim.fn.expand('%:h')
    term.open(cmd, dir)
    vim.cmd [[norm i]]
end

-- }}}
local function highlight()     -- {{{
    -- override some highlights
    vim.cmd [[
            hi! link Folded Boolean
            hi! DiffChange guibg=#18384B
            hi! DiffDelete guifg=Grey
            hi! default link Title Boolean
            hi! DiagnosticSignInfo guifg=Green
            hi! DiagnosticSignHint guifg=Cyan
            hi! DiagnosticSignError guifg=Red
            hi! DiagnosticSignWarn guifg=Yellow
            hi! DiagnosticUnderlineError gui=undercurl guisp=Red
            hi! DiagnosticUnderlineWarn gui=undercurl guisp=Yellow
            hi! DiagnosticUnderlineHint gui=undercurl guisp=Cyan
            hi! DiagnosticUnderlineInfo gui=undercurl guisp=Green
        ]]
end

-- }}}

-- }}}

-- mappings {{{
-- do what needs to be done
vim.keymap.set("n", "<c-p>", exec_first_line_cmd)
-- -- show git status
-- vim.keymap.set('n', '<leader>g', git)
-- scroll by page
vim.keymap.set('n', '<space>', '<c-f>')
vim.keymap.set('n', '<c-space>', '<c-b>')
vim.keymap.set('n', '<s-space>', '<c-b>')
-- copy till the end of line
vim.keymap.set('n', 'Y', 'y$')
-- also for wrapped lines
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
vim.keymap.set('n', '^', 'g^')
vim.keymap.set('n', '0', 'g0')
vim.keymap.set('n', '$', 'g$')
vim.keymap.set('n', '<Up>', 'g<Up>')
vim.keymap.set('n', '<Down>', 'g<Down>')
-- using tab for switching buffers
vim.keymap.set('n', '<tab>', function() tabs.go(vim.api.nvim_get_vvar('count')) end)
-- switch windows using `
vim.keymap.set('n', '`', function() tabs.go(vim.api.nvim_get_vvar('count'), true) end)
-- go forward (back) with backspace
vim.keymap.set('n', '<bs>', '<c-o>')
vim.keymap.set('n', '<s-bs>', '<c-i>')
-- go normal
vim.keymap.set({ 'c', 'v', 'i', 'o' }, 'kj', '<esc>')
vim.keymap.set('t', 'kj', '<C-\\><C-n>')
-- delete a character
vim.keymap.set('c', '<c-h>', '<c-bs>')
-- open/close terminal pane
vim.keymap.set('n', '<leader>t', term.open)
-- open big terminal window / maximize
vim.keymap.set('n', '<leader>T', function() term.open(1) end)
-- closing current buffer
vim.keymap.set({ 'n', 't' }, '<leader>x', tabs.close)
-- save file if changed
vim.keymap.set('n', '<leader><leader>', function() vim.cmd('update!') end)
-- toggle spell check
vim.keymap.set('n', '<leader>z', function() vim.cmd('setlocal spell! spelllang=en_us') end)
-- quit
vim.keymap.set('n', '<leader><esc>', function() vim.cmd('qa') end)
-- enter window commands
vim.keymap.set('n', '<leader>w', '<c-w>')
-- use system clipboard
vim.keymap.set({'n', 'v'}, '<leader>c', '"+')

-- }}}

-- autocmds {{{
local augroup = vim.api.nvim_create_augroup('init', {})
-- override some colors
vim.api.nvim_create_autocmd('VimEnter', {
    group = augroup,
    pattern = '*',
    callback = highlight
})
-- source configs on save
vim.api.nvim_create_autocmd('BufWritePost', {
    group = augroup,
    pattern = { '*.vim', '*.lua' },
    command = 'source %',
})
-- toggle line number formats
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'WinEnter' }, {
    group = augroup,
    pattern = '*',
    callback = function()
        if vim.api.nvim_get_option_value('number', {win = 0}) and vim.api.nvim_get_mode().mode ~= 'i' then
            vim.api.nvim_set_option_value('relativenumber', true, {win = 0})
        end
    end
})
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave' }, {
    group = augroup,
    pattern = '*',
    callback = function() vim.api.nvim_set_option_value('relativenumber', false, {win = 0}) end
})
-- }}}

-- vim:foldmethod=marker:foldlevel=0
