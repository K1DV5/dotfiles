" init script for neovim

" builtins {{{
    "miscellaneous {{{
        " continue wrapped lines with the same indent
        set breakindent
        " use four spaces for tabs
        set tabstop=4 shiftwidth=4 expandtab
        " keep changes persistent after quitting
        set undofile
        " dont highlight matches from last search
        set nohlsearch
        "auto change search to case sensitive when there are upper cases
        set smartcase
        "turn on line numbers where the cursor is (revert: set nonumber)
        set number relativenumber
        "highlight current line
        set cursorline
        " enable true color on terminal
        set termguicolors
        " set the time to update misc things
        set updatetime=100
        " disable swapfiles, allow editing outside nvim
        set noswapfile
        " keep windows the same size when adding/removing
        set noequalalways
        " hide the ~'s at the end of files and other chars
        set fillchars=eob:\ ,diff:\ ,fold:\ ,stl:\  "make it disappear
        " read options only from the first and last lines
        set modelines=1
        " dont show the mode on command line
        set noshowmode
        " split to the right
        set splitright
        " only scan current and other windows for keyword completions
        set complete=.,w,b,t
        " dont be chatty on completions
        set shortmess+=c
        " show diff with vertical split
        set diffopt+=vertical
        " always have a space for signs
        set signcolumn=yes
        " some filetype specific features
        filetype plugin indent on
        " default sql variant
        let g:sql_type_default = 'mysql'
        " disable the tabline
        set showtabline=0
        " to show line numbers on <c-g>, disable on statusline
        set noruler
        " store buffers and cd accross sessions
        set ssop=buffers,curdir
        " use ripgrep
        set grepprg=rg\ --vimgrep
        " allow mouse interaction
        set mouse=a
        " titlebar
        set title titlestring=%t

        "}}}
    "performance {{{
        " hide buffers when not shown in window
        set hidden
        " Don’t update screen during macro and script execution
        set lazyredraw
        " disable remote hosts
        let g:loaded_python_provider = 1
        let g:loaded_python3_provider = 1
        let g:loaded_ruby_provider = 1
        let g:loaded_node_provider = 1
        let g:loaded_perl_provider = 1
        " disable builtin plugins
        let g:loaded_gzip = 1
        let g:loaded_netrw = 1
        let g:loaded_zipPlugin = 1
        let g:loaded_2html_plugin = 1
        let g:loaded_tarPlugin = 1
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
        noremap <tab> <cmd>call TabsGo(v:count)<cr>
        " switch windows using `
        noremap ` <cmd>call TabsGo(v:count/1.0)<cr>
        " fuzzy find file
        noremap - <cmd>call Fuzzy('rg --files ' . repeat('../', v:count))<cr>
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
        let mapleader = ','
        " open/close terminal pane
        noremap <leader>t <cmd>call Term(0.3)<cr>
        tnoremap <leader>t <cmd>call Term(0.3)<cr>
        " open big terminal window
        noremap <leader>T <cmd>call Term(1)<cr>
        tnoremap <leader>T <cmd>call Term(1)<cr>
        " show git status
        noremap <leader>g <cmd>call <sid>git()<cr>
        " closing current buffer
        noremap <leader>bb <cmd>call TabsClose()<cr>
        tnoremap <leader>bb <cmd>call TabsClose()<cr>
        " save file if changed
        noremap <leader>bu <cmd>update!<cr>
        " toggle spell check
        noremap <leader>z <cmd>setlocal spell! spelllang=en_us<cr>
        " quit
        noremap <leader><esc> <cmd>x!<cr>
        " undotree
        noremap <leader>u <cmd>UndotreeToggle<cr>
        " enter window commands
        noremap <leader>w <c-w>
        " use system clipboard
        noremap <leader>c "+
        " toggle file and tag (definition) trees
        noremap <leader>d <cmd>call <sid>tree('Vista', 'vista')<cr>
        noremap <leader>D <cmd>Vista!!<cr>
        noremap <leader>f <cmd>call <sid>tree('NvimTreeOpen', 'NvimTree')<cr>
        noremap <leader>F <cmd>NvimTreeClose<cr>
        "}}}
" }}}
" functions {{{
    function! S(...) "{{{
        " session management
        if a:0 == 0
            let file = 'Session'
            let save = 1
        elseif a:0 == 1
            if type(a:1) == v:t_string
                let file = a:1
                let save = 1
            else  " number
                let file = 'Session'
                let save = a:1
            endif
        else
            let file = a:1
            let save = a:2
        endif
        let file = fnameescape(empty(file) ? stdpath('config') . '/Session' : file) . '.sess'
        if save " save session
            call delete(file)
            execute 'mksession!' file
            return
        endif
        " restore
        if filereadable(file)
            silent execute 'source' file
            edit
        endif
    endfunction

    " }}}
    function! s:gate(direc) "{{{
        " what to do at startup, and exit
        if a:direc == 'in'
            if argc()
                execute 'cd' expand('%:p:h')
            else
                call S('', 0)
                call TabsAllBuffers()
            endif
        elseif !argc()
            " delete terminal buffers
            bufdo if &buftype == 'terminal' | bwipeout! | endif
            call S('', 1)
        endif
    endfunction

    " }}}
    function! s:do() "{{{
        " auto figure out what to do
        silent update!
        wincmd k
        " let s:ext_part = expand('%:e')
        " let l:hidden = ['tex', 'texw', 'html', 'htm']
        " if index(l:hidden, s:ext_part) != -1
        "     setlocal makeprg=do
        "     execute 'make "'.expand('%:p').'"'
        "     echo "Done."
        " else
            call Term('python ' . stdpath('config') . '/do.py '.expand('%:p'))
            norm i
        " endif
    endfunction

    " }}}
    function! s:git() "{{{
        " show git status
        if index(['gina-log', 'gina-status'], &filetype) != -1
            let l:to_be_closed = bufnr()
            call win_gotoid(1000)
            execute 'bdelete' l:to_be_closed
        elseif &modifiable
            Gina status -s --opener=10sp --group=git
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
        hi! LspDiagnosticsVirtualTextInformation guifg=Green
        hi! LspDiagnosticsVirtualTextHint guifg=Cyan
        hi! LspDiagnosticsVirtualTextError guifg=Red
        hi! LspDiagnosticsVirtualTextWarning guifg=Yellow
        hi! LspDiagnosticsUnderlineError gui=undercurl guisp=Red
        hi! LspDiagnosticsUnderlineWarning gui=undercurl guisp=Orange
        hi! LspDiagnosticsUnderlineHint gui=undercurl guisp=Cyan
        hi! LspDiagnosticsUnderlineInformation gui=undercurl guisp=Green
    endfunction

    " }}}
" }}}
" pack config {{{
    "tabs {{{
        " tabs that are not normal buffers
        let g:tabs_custom_stl = {'gina-status': '%f', 'undo': '', 'vista': '', 'gina-commit': ''}
        " show branch if a repo
        let g:tabs_statusline_add = '%{!empty(gina#component#repo#name()) ? " ".gina#component#repo#branch() : ""}'

        " }}}
    "term {{{
        " set default shell to powershell
        let g:term_default_shell = 'powershell'

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
    autocmd VimEnter * nested call s:gate('in') | call s:highlight()
    " save session
    autocmd VimLeavePre * call s:gate('out')
    " use emmet for html
    autocmd FileType html,php,svelte inoremap <c-space> <cmd>call emmet#expandAbbr(0, "")<cr><right>
    " reset tab for vimwiki
    autocmd FileType vimwiki nnoremap <buffer> <tab> <cmd>call TabsGo(v:count)<cr>
    " gc: edit commit message, gp: push, <cr>: commit
    autocmd FileType gina-status noremap <buffer> gc <cmd>Gina commit --group=git<cr> | noremap <buffer> gp <cmd>Gina push<cr>
    autocmd FileType gina-commit inoremap <buffer> <cr> <esc><cmd>wq<cr>
    " close tags window when help opens
    autocmd BufWinEnter *.txt if &buftype == 'help'
        \| wincmd L
        \| vertical resize 83
        \| silent! execute 'Vista!'
        \| endif
    autocmd DirChanged * call S('Session', 0)
    " turn on spelling for prose filetypes
    autocmd FileType markdown,tex setlocal spell
    " source configs on save
    autocmd BufWritePost *.vim,*.lua source %
augroup END
" }}}

" vim:foldmethod=marker:foldlevel=0
