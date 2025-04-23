-- init script for neovim

local o = vim.opt
local g = vim.g

-- set mapleader, should be before lazy
g.mapleader = ','

-- system clipboard
if os.getenv('WSL_DISTRO_NAME') ~= nil then
    vim.g.clipboard = {
        name = 'wsl clipboard',
        copy = { ["+"] = { "clip.exe" }, ["*"] = { "clip.exe" } },
        paste = { ["+"] = { "nvim_paste" }, ["*"] = { "nvim_paste" } },
        cache_enabled = true
    }
end


-- === OPTIONS ===
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
-- disable swapfiles, allow editing outside nvim
o.swapfile = false
-- keep windows the same size when adding/removing
o.equalalways = false
-- reenable jump back to file after closing
o.jumpoptions:remove('clean')
-- read options only from the first and last lines
o.modelines = 1
-- dont show the mode on command line
o.showmode = false
-- split to the right
o.splitright = true
-- dont be chatty on completions
o.shortmess:append('c')
-- show diff with vertical split
o.diffopt:append('vertical')
-- always have a space for signs
o.signcolumn = 'number'
-- disable the tabline
o.showtabline = 0
-- store buffers and cd accross sessions
o.ssop = 'buffers,curdir,localoptions'
-- hide commandline normally
o.cmdheight = 0

-- performance
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

-- === PACKAGES ===

require 'packages'

require'lsp'.setup()
require'tabs'.setup()
local term = require'term'
term.setup()

-- === MAPPINGS ===

-- do what needs to be done
vim.keymap.set("n", "<c-p>", function ()
    vim.cmd [[
      silent update!
      wincmd k
    ]]
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
end)

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
-- go forward (back) with backspace
vim.keymap.set('n', '<bs>', '<c-o>')
vim.keymap.set('n', '<s-bs>', '<c-i>')
vim.keymap.set('n', '<c-bs>', '<c-i>')
-- go normal
vim.keymap.set({ 'c', 'v', 'i', 'o' }, 'kj', '<esc>')
vim.keymap.set('t', 'kj', '<C-\\><C-n>')
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

-- === HIGHLIGHT ===
-- override some colors
vim.cmd [[
  hi! link Folded Boolean
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

-- === AUTOCMDS ===
local augroup = vim.api.nvim_create_augroup('init', {})
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
    if vim.o.number and vim.api.nvim_get_mode().mode ~= 'i' then
      vim.o.relativenumber = true
    end
  end
})
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave' }, {
  group = augroup,
  pattern = '*',
  callback = function() vim.o.relativenumber = false end
})
-- filetype specific indents
vim.api.nvim_create_autocmd({ 'Filetype' }, {
  group = augroup,
  pattern = 'go',
  callback = function() vim.o.expandtab = false end
})
vim.api.nvim_create_autocmd({ 'Filetype' }, {
  group = augroup,
  pattern = 'lua',
  callback = function()
    vim.o.tabstop = 2
    vim.o.shiftwidth = 2
  end
})
