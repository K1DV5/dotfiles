" init script for neovim

let mapleader = ','

lua << EOF
local o = vim.opt
local g = vim.g

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


require"lazy".setup"packages"

-- builtins {{{
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
        o.fillchars = {eob = ' ',diff = ' ',fold = ' ',stl = ' '}
        -- read options only from the first and last lines
        o.modelines = 1
        -- dont show the mode on command line
        o.showmode = false
        -- split to the right
        o.splitright = true
        -- only scan current and other windows for keyword completions
        o.complete='.,w,b,t'
        -- dont be chatty on completions
        o.shortmess:append('c')
        -- show diff with vertical split
        o.diffopt:append('vertical')
        -- always have a space for signs
        o.signcolumn = 'yes'
        -- some filetype specific features
        vim.cmd'filetype plugin indent on'
        -- default sql variant
        g.sql_type_default = 'mysql'
        -- disable the tabline
        o.showtabline = 0
        -- to show line numbers on <c-g>, disable on statusline
        o.ruler = false
        -- store buffers and cd accross sessions
        o.ssop = 'buffers,curdir'
        -- use ripgrep
        o.grepprg = 'rg'
        -- allow mouse interaction
        o.mouse = 'a'
        -- foldtext
        o.foldtext = 'MyFoldText()'

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
EOF

" functions {{{
    function! s:do() "{{{
        " auto figure out what to do
        silent update!
        wincmd k
        call v:lua.term('python3 ' . stdpath('config') . '/do.py '.expand('%:p'))
        norm i
    endfunction

    " }}}
    function! s:git(force) "{{{
        " show git status
        if index(['LazyGit'], &filetype) != -1
            stopinsert
            call feedkeys("\<c-^>")
        elseif &modifiable
            let lg_buf = -1
            for nr in nvim_list_bufs()
                if nvim_buf_get_option(nr, 'filetype') == 'LazyGit'
                    let lg_buf = nr
                    break
                endif
            endfor
            if a:force == 1 && lg_buf != -1
                execute 'bdelete!' lg_buf
                let lg_buf = -1
            endif
            if lg_buf == -1
                execute 'e term://' . expand('%:h') . '//lazygit'
                setlocal filetype=LazyGit nobuflisted
                let b:old_map = maparg('kj', 't')
                augroup lazygit
                autocmd!
                autocmd TermEnter <buffer> tunmap kj
                autocmd TermLeave <buffer> execute 'tnoremap kj' b:old_map
                augroup END
            else
                execute 'buffer' lg_buf
            endif
            startinsert
            if lg_buf != -1
                call feedkeys("2R")
            endif
        else
            echo 'Must be on a file'
        endif
    endfunction

    " }}}
    function! s:cr(insert) "{{{
        if a:insert
            " put the cursor above and below, possibly with indent
            let [_, lnum, cnum, _] = getpos('.')
            let line = getline('.')
            " html
            let html_pairs = ['<\w\+.\{-}>', '</\w\+>']
            let before = trim(line[:cnum-2])
            let after = trim(line[cnum-1:])
            if before =~ '^' . html_pairs[0] . '$' && after =~ '^' . html_pairs[1] . '$'
                return "\<cr>\<esc>O"
            endif
            " other
            let surround = ['([{', ')]}']
            let [i_begin, i_end] = [stridx(surround[0], line[cnum-2]), stridx(surround[1], line[cnum-1])]
            " let not_equal = count(line, surround[0][i_begin]) != count(line, surround[1][i_end])
            if i_begin == -1 || i_begin != i_end || empty(line[cnum-2]) "|| not_equal
                return "\<cr>"
            endif
            return "\<cr>\<esc>O"
        else
            " follow help links with enter
            let l:supported = ['vim', 'help', 'python']
            if index(l:supported, &filetype) != -1
                norm K
            else
                execute "norm! \<cr>"
            endif
        endif
    endfunction

    " }}}
    function! s:tree(command, file_type) "{{{
        " tree jumping and/or opening
        let l:tree_wins = filter(copy(nvim_list_wins()), 'getbufvar(winbufnr(v:val), "&filetype") == "'.a:file_type.'"')
        if l:tree_wins != []
            if &filetype == a:file_type
                wincmd l
                if &filetype == a:file_type " still here
                    wincmd h
                endif
            else
                call win_gotoid(l:tree_wins[0])
            endif
        else
            execute a:command
        endif
    endfunction

    " }}}
    function! s:highlight() "{{{
        " override some highlights
        hi! link Folded Boolean
        hi! DiffChange guibg=#18384B
        hi! DiffDelete guifg=Grey
        hi! default link Title Boolean
        hi! default link VimwikiMarkers Boolean
        hi! default link VimwikiLink markdownUrl
        hi! DiagnosticSignInfo guifg=Green
        hi! DiagnosticSignHint guifg=Cyan
        hi! DiagnosticSignError guifg=Red
        hi! DiagnosticSignWarn guifg=Yellow
        hi! DiagnosticUnderlineError gui=undercurl guisp=Red
        hi! DiagnosticUnderlineWarn gui=undercurl guisp=Yellow
        hi! DiagnosticUnderlineHint gui=undercurl guisp=Cyan
        hi! DiagnosticUnderlineInfo gui=undercurl guisp=Green
    endfunction

    " }}}
    function! MyFoldText() "{{{
        let indentation = indent(v:foldstart) - 1
        " let foldSize = 1 + v:foldend - v:foldstart
        " let foldSizeStr = " x" . foldSize
        let line = getline(v:foldstart)
        if len(line) > 80
            let line = line[:77] . '...'
        endif
        let line = substitute(line, '^\s*\|{', '', 'g')
        let foldLevelStr = '[+] ' . line
        let expansionString = repeat(" ", indentation)
        return expansionString . foldLevelStr ". foldSizeStr
    endfunction
    
    "}}}

" }}}
" mappings {{{
    "normal {{{
        " do what needs to be done
        noremap <c-p> <cmd>call <sid>do()<cr>
        "scroll by page
        noremap <space> <c-f>
        noremap <c-space> <c-b>
        noremap <s-space> <c-b>
        " copy till the end of line
        noremap Y y$
        "also for wrapped lines
        noremap j gj
        noremap k gk
        noremap ^ g^
        noremap 0 g0
        noremap $ g$
        noremap <Up> g<Up>
        noremap <Down> g<Down>
        "using tab for switching buffers
        noremap <tab> <cmd>call v:lua.tabs_go(v:count)<cr>
        " switch windows using `
        noremap ` <cmd>call v:lua.tabs_go(v:count, v:true)<cr>
        " to return to normal mode in terminal and operator pending
        tnoremap kj <C-\><C-n>
        onoremap kj <esc>
        " do the same thing as normal mode in terminal for do
        tnoremap <c-p> <C-\><C-n><cmd>call <sid>do()<cr>
        " lookup help for something under cursor with enter
        nnoremap <cr> <cmd>call <sid>cr(0)<cr>
        " go forward (back) with backspace
        noremap <bs> <c-o>
        noremap <s-bs> <c-i>

        "}}}
    "command {{{
        " go normal
        cnoremap kj <esc>
        " delete a character
        cnoremap <c-h> <c-bs>

        "}}}
    "insert {{{
        " escape quick
        imap kj <esc>
        " nice brackets on cr
        " imap <expr> <cr> <sid>cr(v:true)
        "}}}
    "visual {{{
        " escape quick
        vnoremap kj <esc>

        "}}}
    " leader {{{
        " open/close terminal pane
        noremap <leader>t <cmd>call v:lua.term()<cr>
        tnoremap <leader>t <cmd>call v:lua.term()<cr>
        " open big terminal window
        noremap <leader>T <cmd>call v:lua.term(1)<cr>
        tnoremap <leader>T <cmd>call v:lua.term(1)<cr>
        " show git status
        noremap <leader>g <cmd>call <sid>git(0)<cr>
        noremap <leader>G <cmd>call <sid>git(1)<cr>
        tnoremap <leader>g <cmd>call <sid>git(0)<cr>
        " closing current buffer
        noremap <leader>bb <cmd>lua tabs_close()<cr>
        tnoremap <leader>bb <cmd>lua tabs_close()<cr>
        " save file if changed
        noremap <leader>bu <cmd>update!<cr>
        " toggle spell check
        noremap <leader>z <cmd>setlocal spell! spelllang=en_us<cr>
        " quit
        noremap <leader><esc> <cmd>qa<cr>
        " enter window commands
        noremap <leader>w <c-w>
        " use system clipboard
        noremap <leader>c "+
        " toggle file and tag (definition) trees
        noremap <leader>d <cmd>call <sid>tree('AerialOpen', 'aerial')<cr>
        noremap <leader>D <cmd>AerialClose<cr>
        "}}}
" }}}
" pack config {{{
    "term {{{
        " set default shell to powershell

        " }}}
    "vimwiki {{{
        " disable tab in insert
        let g:vimwiki_table_mappings = 0
        " custom path
        let g:vimwiki_list = [{'path': 'D:\Documents\Notes\', 'syntax': 'markdown', 'ext': '.md'}]

        " }}}
    "signify {{{
        " work only with git
        let g:signify_vcs_list = ['git']
        " show only colors
        " let g:signify_sign_add               = ' '
        " let g:signify_sign_delete            = ' '
        " let g:signify_sign_delete_first_line = ' '
        " let g:signify_sign_change            = ' '
        " let g:signify_sign_change_delete     = g:signify_sign_change . g:signify_sign_delete_first_line

        " }}}
    "undotree {{{
        " short timestamps
        let g:undotree_ShortIndicators = 1
        " autofocus
        let g:undotree_SetFocusWhenToggle = 1
        " disable diff win
        let g:undotree_DiffAutoOpen = 0

        " }}}
    " vista {{{
        " show definition in floating win
        let g:vista_echo_cursor_strategy = 'floating_win'
        " to use my own statusline
        let g:vista_disable_statusline = 1
        " }}}
" }}}
augroup init "{{{
    autocmd!
    "resume session, override some colors
    autocmd VimEnter * nested call s:highlight()
    " use emmet for html
    autocmd FileType html,php,svelte inoremap <c-space> <cmd>call emmet#expandAbbr(0, "")<cr><right>
    " close tags window when help opens
    autocmd BufWinEnter *.txt if &buftype == 'help'
        \| wincmd L
        \| vertical resize 83
        \| silent! execute 'SymbolsOutlineClose'
        \| endif
    " turn on spelling for prose filetypes
    autocmd FileType markdown,tex setlocal spell
    " source configs on save
    autocmd BufWritePost *.vim,*.lua source %
    " toggle line number formats
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &number && mode() != "i" | set relativenumber | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * set norelativenumber
augroup END
" }}}

" vim:foldmethod=marker:foldlevel=0
