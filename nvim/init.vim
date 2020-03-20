" init script for neovim

" builtins {{{
    "miscellaneous {{{
        " continue wrapped lines with the same indent
        set breakindent
        " use four spaces for tabs
        set tabstop=4 shiftwidth=4 expandtab
        " keep changes persistent after quitting
        set undofile
        "highlight matches from last search
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

    "}}}
" functions {{{
    function! Session(file, save) "{{{
        let session_file = fnameescape(empty(a:file) ? stdpath('config') . '/Session' : a:file) . '.sess'
        if a:save " save session
            execute 'mksession!' session_file
            return
        endif
        " restore
        if filereadable(session_file)
            silent execute 'source' session_file
        else
            echo 'No Session File'
        endif
    endfunction

    " }}}
    function! EntArgs(event) "{{{
        " what to do at startup, and exit
        if a:event == 'enter'
            if argc() == 0
                call Session('', 0)
                call TabsAllBuffers()
            else
                execute 'cd' expand('%:p:h')
                if empty(bufname())
                    bdelete
                endif
            endif
        else
            if argc() == 0
                " delete terminal buffers
                bufdo if &buftype == 'terminal' | bwipeout! | endif
                call Session('', 1)
            endif
        endif
    endfunction

    " }}}
    function! Please_Do() "{{{
        " auto figure out what to do
        wincmd k
        let s:ext_part = expand('%:e')
        silent update!
        let l:hidden = ['tex', 'texw', 'html', 'htm']
        if index(l:hidden, s:ext_part) != -1
            execute 'setlocal makeprg=do'
            execute 'make "'.expand('%:p').'"'
            echo "Done."
        else
            call Term('do '.expand('%:p'))
            norm i
        endif
    endfunction

    " }}}
    function! GitStat() "{{{
        " show git status
        if index(['gitcommit', 'fugitive', 'gina-log', 'gina-status'], &filetype) != -1
            let l:to_be_closed = bufnr()
            call win_gotoid(1000)
            execute 'bdelete' l:to_be_closed
        elseif &modifiable
            Gina status -s --opener=sp
        else
            echo 'Must be on a file'
        endif
    endfunction

    " }}}
    function! CRFunc() abort "{{{
        " follow help links with enter
        let l:supported = ['vim', 'help', 'python']
        if index(l:supported, &filetype) != -1
            norm K
        else
            execute "norm! \<cr>"
        endif
    endfunction

    " }}}
    function! LSP() abort "{{{
        " lsp config
        lua << EOF
            -- disable disgnostics in insert mode:

            local default_callback = vim.lsp.callbacks["textDocument/publishDiagnostics"]
            local err, method, params, client_id

            vim.lsp.callbacks["textDocument/publishDiagnostics"] = function(...)
                err, method, params, client_id = ...
                local mode = vim.api.nvim_get_mode().mode
                if mode ~= "i" and mode ~= "ic" then
                    publish_diagnostics()
                end
            end

            function publish_diagnostics()
                default_callback(err, method, params, client_id)
            end

            local nvim_lsp = require('nvim_lsp')
            local setmap = vim.api.nvim_buf_set_keymap

            local on_attach = function(_, bufnr)
                vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')  -- completion
                vim.api.nvim_command [[autocmd InsertLeave <buffer> lua publish_diagnostics()]]  -- show diagnostics
                vim.api.nvim_command [[autocmd InsertEnter <buffer> call v:lua.vim.lsp.util.buf_clear_diagnostics(bufnr())]]  -- hide diagnostics

                -- Mappings

                local opts = {noremap=true, silent=true}
                setmap(bufnr, 'n', '<c-]>',  '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
                setmap(bufnr, 'n',  'gd',    '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
                setmap(bufnr, 'n',  'K',     '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
                setmap(bufnr, 'n',  'gD',    '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
                setmap(bufnr, 'n',  '<c-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
                setmap(bufnr, 'n',  '1gD',   '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
                setmap(bufnr, 'n',  'gr',    '<cmd>lua vim.lsp.buf.references()<CR>', opts)
            end

            local servers = {'pyls', 'texlab', 'tsserver'}
            for _, lsp in ipairs(servers) do
                nvim_lsp[lsp].setup{on_attach=on_attach}
            end
EOF
    endfunction

    " }}}
    function! LSPcoc() abort "{{{
        let fts = ['python', 'javascript', 'svelte']
        augroup lsp_coc
            autocmd!
            execute 'autocmd FileType' join(fts, ',') 'nmap <leader>sr <Plug>(coc-rename)'
        augroup END
    endfunction

    " }}}
    function! Complete(direction) "{{{
        " direction: 1-forward, 2-backward, 0-show
        " when pressing tab in insert mode...
        if pumvisible()
            if a:direction
                if a:direction == 1 "without shift, forward
                    return "\<c-n>"
                endif
                " with shift, back
                return "\<c-p>"
            endif
        endif
        let chars = 2  " chars before triggering
        let pattern = '\(\w\|\d\)\{' . chars . '}'
        let col = col('.') - 1
        let line = getline('.')
        let last_chars = line[col-chars:col-1]
        if !a:direction && last_chars !~# pattern || !col || last_chars[chars-1] =~ '\s'
            " not at a completeable place
            return "\<tab>"
        endif
        " prevent keyword completion from making nvim unresponsive
        " check th[es]e| chars for previous attempts
        let before_match = line[col-chars-1:col-2]
        if !a:direction && len(before_match) && before_match =~# pattern
            return ''
        endif
        call feedkeys("\<c-n>")  " keyword completion
        if &omnifunc == 'v:lua.vim.lsp.omnifunc'  " lsp
            execute 'call' &omnifunc . '(0, "")'
        endif
        return ''
    endfunction

    " }}}
    function! HandleTree(command, file_type) abort "{{{
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
    function! OpenFile(arg) abort "{{{
        " open binary files as double click and text files here
        if empty(a:arg)
            return
        endif
        if a:arg[0] == 'ctrl-r'
            let destination = getcwd() . '/' . input('dest: ', a:arg[1])
            if destination != a:arg[0]
                execute 'silent! !move' a:arg[1] destination
            endif
            return
        endif
        for line in readfile(a:arg[1], 'b', 10)
            if line =~ nr2char(10)  " binary
                execute 'silent! !start' a:arg[1]
                return
            endif
        endfor
        execute 'e' a:arg[1]
    endfunction

    " }}}
    function! Highlight() abort "{{{
        " override some highlights
        hi! link Folded Boolean
        hi! DiffChange guibg=#18384B
        hi! DiffDelete guifg=Grey
        hi! default link Title Boolean
        hi! default link VimwikiMarkers Boolean
        hi! default link VimwikiLink markdownUrl
    endfunction

    " }}}
    function! MyFold() abort "{{{
        " better folding
        let patt = &commentstring[:stridx(&commentstring, '%s')-1].'\|{{{'
        let fold_line = repeat('   ', v:foldlevel - 1) . ' ' . trim(substitute(getline(v:foldstart), patt, '', 'g'))
        return fold_line
        " }}}, keep the markers balanced
    endfunction

    " }}}

    "}}}
" mappings {{{
    "Normal_mode {{{
        " do what needs to be done
        noremap <c-p> <cmd>call Please_Do()<cr>
        " move lines up down
        noremap <a-k> <cmd>move-2<cr>
        noremap <a-j> <cmd>move+1<cr>
        "scroll by page
        noremap <space> <c-f>
        noremap <c-space> <c-b>
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
        " fuzzy find files, count means that much up dir
        " noremap - <cmd>execute 'FZF' repeat('../', v:count)<cr>
        noremap - <cmd>call fzf#run({'source': 'rg --files '.repeat('../', v:count), 'sink*': funcref('OpenFile'), 'down': '30%', 'options': '--expect=ctrl-r'})<cr>
        " to return to normal mode in terminal
        tnoremap kj <C-\><C-n>
        " do the same thing as normal mode in terminal for do
        tnoremap <c-p> <C-\><C-n><cmd>call Please_Do()<cr>
        " lookup help for something under cursor with enter
        nnoremap <cr> <cmd>call CRFunc()<cr>
        " go forward (back) with backspace
        noremap <c-h> <c-o>
        noremap <bs> <c-i>

        "}}}
    "Command_mode {{{
        " paste on command line
        cnoremap <c-v> <c-r>*
        " go normal
        cnoremap kj <esc>
        " delete a character
        cnoremap <c-h> <c-bs>

        "}}}
    "Insert_mode {{{
        " escape quick
        imap kj <esc>
        " move one line up and down
        inoremap <up> <cmd>norm gk<cr>
        inoremap <down> <cmd>norm gj<cr>
        " cut
        vnoremap <c-x> <cmd>norm d<cr>
        " copy
        vnoremap <c-c> <cmd>norm y<cr>
        " paste
        inoremap <c-v> <cmd>norm gP<cr>
        " undo
        inoremap <c-z> <cmd>undo<cr>
        " redo
        inoremap <c-y> <cmd>redo<cr>
        " delete word
        inoremap <c-bs> <cmd>norm bdw<cr>
        inoremap <c-del> <cmd>norm dw<cr>
        " " go through suggestions or jump to snippet placeholders
        imap <expr> <tab> Complete(1)
        imap <expr> <s-tab> Complete(-1)
        smap <expr> <tab> Complete(1)

        "}}}
    "Visual_mode {{{
        " escape quick
        vnoremap kj <esc>
        vnoremap KJ <esc>
        " search for selected text
        vnoremap // y/<c-r>"<cr>

        "}}}
    "With_leader_key {{{
        let mapleader = ','
        " open/close terminal pane
        noremap <leader>t <cmd>call Term(0.3)<cr>
        tnoremap <leader>t <cmd>call Term(0.3)<cr>
        " open big terminal window
        noremap <leader>T <cmd>call Term(1)<cr>
        tnoremap <leader>T <cmd>call Term(1)<cr>
        " show git status
        noremap <leader>g <cmd>call GitStat()<cr>
        " closing current buffer
        noremap <leader>bb <cmd>call TabsClose()<cr>
        tnoremap <leader>bb <cmd>call TabsClose()<cr>
        " save file if changed and source if it is a vim file
        noremap <expr> <leader>bu &filetype == 'vim' ? '<cmd>update! \| source %<cr>' : '<cmd>update!<cr>'
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
        noremap <leader>d <cmd>call HandleTree('Vista', 'vista')<cr>
        noremap <leader>D <cmd>Vista!!<cr>
        "}}}

    "}}}
" plugins {{{
    "Management {{{
        " managing func, lazy loads minpac first
        function! Pack() abort
            packadd minpac
            call minpac#init()
            call minpac#add('k-takata/minpac', {'type': 'opt'})
            call minpac#add('tpope/vim-commentary')
            call minpac#add('tpope/vim-surround')
            " call minpac#add('neovim/nvim-lsp')
            " call minpac#add('haorenW1025/completion-nvim')
            call minpac#add('neoclide/coc.nvim', {'branch': 'release'})
            call minpac#add('junegunn/fzf')
            call minpac#add('jiangmiao/auto-pairs')
            call minpac#add('mhinz/vim-signify')
            call minpac#add('mbbill/undotree')
            call minpac#add('liuchengxu/vista.vim')
            call minpac#add('michaeljsmith/vim-indent-object')
            call minpac#add('K1DV5/vim-code-dark')
            call minpac#add('ferrine/md-img-paste.vim')
            call minpac#add('mattn/emmet-vim')
            call minpac#add('lambdalisue/gina.vim')
            call minpac#add('justinmk/vim-sneak')
            call minpac#add('sheerun/vim-polyglot')
            call minpac#add('vimwiki/vimwiki')
        endfunction

        " }}}
    "coc {{{
        let g:coc_global_extensions = ['coc-tsserver', 'coc-python', 'coc-json', 'coc-html', 'coc-css', 'coc-texlab', 'coc-svelte']

        " }}}
    "devicons {{{
        "folder icons
        let g:WebDevIconsUnicodeDecorateFolderNodes = 1
        let g:DevIconsEnableFoldersOpenClose = 1
        let g:DevIconsEnableFolderExtensionPatternMatching = 1

        " }}}
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
    "scratch {{{
        " split vertically
        let g:scratch_horizontal = 0
        " open on the right side
        let g:scratch_top = 0
        " set {} of the current width
        let g:scratch_height = 0.3
        " make persistent between sessions
        let g:scratch_persistence_file = '~/Documents/Code/.res/nvim/scratch.txt'
        " don't hide the scratch buffer on InsertLeave or window leave
        let g:scratch_insert_autohide = 0
        let g:scratch_autohide = 0

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
        " hide numbers
        " let g:signify_sign_show_count = 0

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

    "}}}
augroup init "{{{
    autocmd!
    "resume session, override some colors
    autocmd VimEnter * nested call EntArgs('enter') | call Highlight() | call LSPcoc() "| call LSP()
    "save session
    autocmd VimLeavePre * call EntArgs('leave')
    " completion
    " autocmd TextChangedI * call Complete(0)
    " highlight where lines should end and map for inline equations for latex
    " use emmet for html
    autocmd FileType html,php inoremap <c-space> <cmd>call emmet#expandAbbr(0, "")<cr><right>
    " reset tab for vimwiki
    autocmd FileType vimwiki nnoremap <buffer> <tab> <cmd>call TabsGo(v:count)<cr>
    " gc: edit commit message, gp: push, <cr>: commit
    autocmd FileType gina-status noremap <buffer> gc <cmd>Gina commit<cr> | noremap <buffer> gp <cmd>Gina push<cr>
    autocmd FileType gina-commit inoremap <buffer> <cr> <esc><cmd>wq<cr>
    " close tags window when help opens
    autocmd BufWinEnter *.txt if &buftype == 'help'
        \| wincmd L
        \| vertical resize 83
        \| silent! execute 'Vista!'
        \| endif
augroup END
"}}}

" vim:foldmethod=marker:foldlevel=0:foldtext=MyFold()
