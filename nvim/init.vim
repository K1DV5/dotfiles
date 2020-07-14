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
        " only show menu when completing
        set completeopt=menuone,noinsert,noselect
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
        " fold text for this file
        set foldtext=MyFold()
        " allow expressions in modelines
        set modelineexpr
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
        " make windows aquashable to just the statusbar
        set winminheight=0

        "}}}
    "performance {{{
        " hide buffers when not shown in window
        set hidden
        " Don’t update screen during macro and script execution
        set lazyredraw
        " disable python 2
        let g:loaded_python_provider = 1
        " disable ruby
        let g:loaded_ruby_provider = 1
        " disable node.js
        let g:loaded_node_provider = 1
        " set python path
        let g:python3_host_prog = 'D\DevPrograms\Python\python'
        let g:python_host_prog = 'D\DevPrograms\Python\python'
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
        " move lines up down
        noremap <a-k> <cmd>move-2<cr>
        noremap <a-j> <cmd>move+1<cr>
        "scroll by page
        noremap <space> <c-f>
        noremap <c-space> <c-b>
        noremap <s-space> <c-b>
        "select all ctrl a
        noremap <c-a> ggVG
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
        " paste on command line
        cnoremap <c-v> <c-r>*
        " go normal
        cnoremap kj <esc>
        " delete a character
        cnoremap <c-h> <c-bs>

        "}}}
    "insert {{{
        " escape quick
        imap kj <esc>
        " pairs
        inoremap ( ()<left>
        " inoremap ( <cmd>lua vim.lsp.buf.signature_help()<cr>
        inoremap { {}<left>
        inoremap [ []<left>
        inoremap " ""<left>
        inoremap ' ''<left>
        inoremap ` ``<left>
        inoremap <expr> <bs> <sid>delp()
        inoremap <expr> <cr> <sid>cr(1)

        "}}}
    "visual {{{
        " escape quick
        vnoremap kj <esc>
        vnoremap KJ <esc>
        " search for selected text
        vnoremap // y/<c-r>"<cr>

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
        " save file if changed and source if it is a vim file
        noremap <expr> <leader>bu '<cmd>update!' . (&filetype == 'vim' ? '\| source %' : '') . '<cr>'
        " toggle spell check
        noremap <leader>z <cmd>setlocal spell! spelllang=en_us<cr>
        " quit
        noremap <leader><esc> <cmd>xall!<cr>
        " undotree
        noremap <leader>u <cmd>UndotreeToggle<cr>
        " enter window commands
        noremap <leader>w <c-w>
        " use system clipboard
        noremap <leader>c "+
        " toggle file and tag (definition) trees
        noremap <leader>d <cmd>call <sid>tree('Vista', 'vista')<cr>
        noremap <leader>D <cmd>Vista!!<cr>
        "}}}
" }}}
" functions {{{
    function! P() "{{{
        " plugin management, lazy loads minpac first
        packadd minpac
        call minpac#init()
        call minpac#add('k-takata/minpac', {'type': 'opt'})
        call minpac#add('tpope/vim-commentary')
        call minpac#add('tpope/vim-surround')
        call minpac#add('neovim/nvim-lsp')
        call minpac#add('mhinz/vim-signify')
        call minpac#add('mbbill/undotree')
        call minpac#add('liuchengxu/vista.vim')
        call minpac#add('tomasiser/vim-code-dark')
        call minpac#add('ferrine/md-img-paste.vim', {'type': 'opt'})
        call minpac#add('mattn/emmet-vim')
        call minpac#add('lambdalisue/gina.vim')
        call minpac#add('justinmk/vim-sneak')
        call minpac#add('sheerun/vim-polyglot')
        call minpac#add('vimwiki/vimwiki')
    endfunction

    " }}}
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
    function! MyFold() "{{{
        " better folding
        let patt = &commentstring[:stridx(&commentstring, '%s')-1].'\|{{{'
        let fold_line = repeat('   ', v:foldlevel - 1) . ' ' . trim(substitute(getline(v:foldstart), patt, '', 'g'))
        return fold_line
        " }}}, keep the markers balanced
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
        wincmd k
        let s:ext_part = expand('%:e')
        silent update!
        let l:hidden = ['tex', 'texw', 'html', 'htm']
        if index(l:hidden, s:ext_part) != -1
            setlocal makeprg=do
            execute 'make "'.expand('%:p').'"'
            echo "Done."
        else
            call Term('do '.expand('%:p'))
            norm i
        endif
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
        hi! LspDiagnosticsInformation guifg=Green
        hi! LspDiagnosticsHint guifg=Cyan
        hi! LspDiagnosticsUnderlineError gui=undercurl guisp=Red
        hi! LspDiagnosticsUnderlineWarning gui=undercurl guisp=Orange
        hi! LspDiagnosticsUnderlineHint gui=undercurl guisp=Cyan
        hi! LspDiagnosticsUnderlineInformation gui=undercurl guisp=Green
    endfunction

    " }}}
    function! s:delp() "{{{
        " delete a pair of parens...
        let col = col('.')
        let line = getline('.')
        let pairs = ['()', '[]', '{}', '""', "''", '``']
        let left = line[col-2]
        let right = line[col-1]
        if index(pairs, line[col-2:col-1]) > -1 && count(line, left) == count(line, right)
            return "\<bs>\<del>" 
        endif
        return "\<bs>"
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
    "python_syntax {{{
        " enable all highlighting
        let g:python_highlight_all = 1
        let g:python_highlight_operators = 0
        let g:python_highlight_space_errors = 0
        let g:python_highlight_indent_errors = 0

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
        let g:signify_sign_show_text = 0

        " }}}
    "undotree {{{
        " short timestamps
        let g:undotree_ShortIndicators = 1
        " autofocus
        let g:undotree_SetFocusWhenToggle = 1
        " disable diff win
        let g:undotree_DiffAutoOpen = 0

        " }}}
    "sneak {{{
        " Make it like easymotion
        let g:sneak#label = 1
        " always ; forward
        let g:sneak#absolute_dir = 1

        "}}}
    " vista {{{
        " show definition in floating win
        let g:vista_echo_cursor_strategy = 'floating_win'
        " to use my own statusline
        let g:vista_disable_statusline = 1
        " }}}
    "colorscheme {{{
        if get(g:, 'colors_name', 'default') == 'default'
            " Use colors that suit a dark background
            set background=dark
            " Change colorscheme
            colorscheme codedark
        endif

        " }}}
" }}}
augroup init "{{{
    autocmd!
    "resume session, override some colors
    autocmd VimEnter * nested call s:gate('in') | call s:highlight() | lua require 'lsp'
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
augroup END
" }}}

" vim:foldmethod=marker:foldlevel=0
