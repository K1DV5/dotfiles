" init script for neovim

" BUILTINS: {{{

    "Miscellaneous: {{{
        "make search case insensitive
        set ignorecase
        " continue wrapped lines with the same indent
        set breakindent
        " use four spaces for tabs
        set tabstop=4 shiftwidth=4 expandtab
        " keep changes persistent after quitting
        set undofile
        "show incomplete commands to the right of the command window
        set showcmd
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
        " disable swapfiles
        set noswapfile
        " add the ginit path as environment variable
        let $MYGVIMRC = stdpath('config').'/ginit.vim'
        " keep windows the same size when adding/removing
        set noequalalways
        " hide the ~'s at the end of files
        set fillchars=eob:\ ,diff:\ ,fold:\ ,stl:\  "make it disappear
        " keep some lines visible at top/bottom when scrolling
        " set scrolloff=3
        " read only the first and last lines
        set modelines=1
        " print info on cmdline
        set noshowmode
        " split to the right
        set splitright
        " only show menu when completing
        set completeopt=menu,noinsert,noselect,menuone
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
        " allow mouse interaction
        set mouse=n
        " disable the tabline
        set showtabline=0
        " to show line numbers on <c-g>, disable on statusline
        set noruler

        "}}}
    "Performance: {{{
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
        let g:python3_host_prog = 'D:\DevPrograms\Python\python'
        let g:python_host_prog = 'D:\DevPrograms\Python\python'
        " disable builtin plugins
        let g:loaded_gzip = 1
        let g:loaded_netrw = 1
        let g:loaded_zipPlugin = 1
        let g:loaded_2html_plugin = 1
        let g:loaded_tarPlugin = 1
        "}}}

    "}}}
" MAPPINGS: {{{

    "Normal_mode: {{{
        " do what needs to be done
        noremap <c-p> <cmd>call Please_Do()<cr>
        " move lines up down
        noremap <a-k> <cmd>move-2<cr>
        noremap <a-j> <cmd>move+1<cr>
        "scroll by space and [shift] space
        noremap <space> <c-f>
        noremap <c-space> <c-b>
        "select all ctrl a
        noremap <c-a> ggVG
        " copy till the end of line
        noremap Y y$
        "move around windows with ctrl directions
        noremap <c-h> <c-w>h
        noremap <c-j> <c-w>j
        noremap <c-k> <c-w>k
        noremap <c-l> <c-w>l
        "also for wrapped lines
        noremap j gj
        noremap k gk
        noremap ^ g^
        noremap 0 g0
        noremap $ g$
        noremap <Up> g<Up>
        noremap <Down> g<Down>
        "using [shift] tab for switching buffers
        noremap <tab> <cmd>call TabsGo(v:count)<cr>
        noremap <s-tab> <cmd>call TabsNext()<cr>
        " to return to normal mode in terminal
        tnoremap kj <C-\><C-n>
        " do the same thing as normal mode in terminal for do
        tnoremap <c-p> <C-\><C-n><cmd>call Please_Do()<cr>
        " lookup help for something under cursor with enter
        nnoremap <cr> <cmd>call CRFunc()<cr>
        " go back with [shift] backspace
        nnoremap <bs> <esc><c-o>
        nnoremap <s-bs> <esc><c-i>
        " disable the arrow keys
        noremap <up> <nop>
        noremap <down> <nop>
        noremap <left> <nop>
        noremap <right> <nop>

        "}}}
    "Command_mode: {{{
        " paste on command line
        cnoremap <c-v> <c-r>*
        cnoremap <c-h> <cmd>norm h<cr>
        cnoremap <c-j> <cmd>norm gj<cr>
        cnoremap <c-k> <cmd>norm gk<cr>
        cnoremap <c-l> <cmd>norm l<cr>
        " go normal
        cnoremap kj <esc>

        "}}}
    "Insert_mode: {{{
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
        " imap <expr> <tab> Itab(1)
        " imap <expr> <s-tab> Itab(0)
        " smap <expr> <tab> Itab(0)

        "}}}
    "Visual_mode: {{{
        " escape quick
        vnoremap kj <esc>
        vnoremap KJ <esc>
        " search for selected text
        vnoremap // y/<c-r>"<cr>
        " change all instances of selected text
        vnoremap /c <cmd>call Subs('all')<cr>
        " change something in current selection (sep by double space)
        vnoremap /w <cmd>call Subs('within')<cr>

        "}}}
    "With_leader_key: {{{
        let mapleader = ','
        " open/close terminal pane
        noremap <leader>t <cmd>call Term(0.3)<cr>
        tnoremap <leader>t <cmd>call Term(0.3)<cr>
        " open big terminal window
        noremap <leader>T <cmd>call Term(1)<cr>
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
        " change current line to latex
        noremap <leader>xi <cmd>call Latexify(0)<cr>
        noremap <leader>xd <cmd>call Latexify(1)<cr>
        " automate itemize and enumerate
        noremap <leader>xl <cmd>call ItemizeEnum()<cr>
        " paste image to latex properly
        noremap <leader>ip <cmd>call InsertClipFigTex()<cr>
        " remove unused pasted images in latex
        noremap <leader>ir <cmd>call PurgeUnusedImagesTex()<cr>
        " using leader [shift] tab for switching windows
        noremap <leader><tab> <cmd>call SwitchWin()<cr>
        " use system clipboard
        noremap <leader>c "+
        " toggle file and tag (definition) trees
        noremap <leader>f <cmd>call fzf#run({"window": {"width": 0.6, "height": 0.6}, "dir": repeat("../", v:count), "sink": "e"})<cr>
        noremap <leader>d <cmd>call HandleTree('Vista', 'vista')<cr>
        noremap <leader>D <cmd>Vista!!<cr>
        "}}}

    "}}}
" FUNCTIONS: {{{

    function! ResumeSession(file) "{{{
        " to resume a session
        if a:file == ""
            let l:session_file = '~/AppData/Local/nvim/Session'
        else
            let l:session_file = a:file
        endif
        try
            silent execute 'source' fnameescape(l:session_file.'.sess')
        catch
            echo 'No Session File'
        endtry
    endfunction

    " }}}
    function! SaveSession(file) "{{{
        " to save a session
        if a:file == ""
            let l:session_file = '~/AppData/Local/nvim/Session'
        else
            let l:session_file = a:file
        endif
        execute 'mksession!' fnameescape(l:session_file.'.sess')
    endfunction

    " }}}
    function! EntArgs(event) "{{{
        " what to do at startup, and exit
        if a:event == 'enter'
            " setup lsp
            call LSP()
            if argc() == 0
                call ResumeSession('')
                call TabsAllBuffers()
            else
                execute 'cd' expand('%:p:h')
                if bufname('%') == ''
                    bdelete
                endif
            endif
        else
            if argc() == 0
                " delete terminal buffers
                bufdo if &buftype == 'terminal' | bwipeout! | endif
                call SaveSession('')
            else
                argd *
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
        let l:cwd = getcwd()
        cd %:h
        let script = 'D:/Documents/Code/.dotfiles/misc/do.py'
        if index(l:hidden, s:ext_part) != -1
            execute 'setlocal makeprg=python\' script
            execute 'make "'.expand('%:p').'"'
            echo "Done."
        else
            call Term('python '.script.' '.expand('%:t'))
            " call Term('do '.expand('%:t'))
            norm i
        endif
        execute 'cd' l:cwd
    endfunction

    " }}}
    function! SwitchWin() abort "{{{
        " switch windows, works with autocmd WinLeave to save the win id
        " let temp_alt_win = win_getid()
        if !(exists('g:init_alt_win') && win_getid() != g:init_alt_win && win_gotoid(g:init_alt_win))
            execute "norm! \<c-w>w"
        endif
        " let g:init_alt_win = temp_alt_win
    endfunction

    " }}}
    function! Subs(where) abort "{{{
        " substitute in visual selection
        if a:where == 'all'
            silent norm y
            let l:oldt = @"
            let l:newt = input('>', l:oldt)
            if l:newt == '' || l:newt == l:oldt
                return
            endif
            execute '%s#'.l:oldt.'#'.l:newt.'#g'
            norm ''
        else
            let l:subs = split(input('>'), '  ')
            if len(l:subs) < 2
                return
            endif
            execute "'<,'>s/".l:subs[0]."/".l:subs[1]."/g"
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
    function! ContextSyntax(host, guest, start, end) "{{{
        " Syntax highlighting based on the context range (modified from
        " brotchie/python-sty)
        execute 'setfiletype' a:host
        let b:current_syntax = ''
        unlet b:current_syntax
        execute 'runtime! syntax/'.a:host.'.vim'
        let b:current_syntax = ''
        unlet b:current_syntax
        execute 'syntax include @Host syntax/'.a:host.'.vim'
        let b:current_syntax = ''
        unlet b:current_syntax
        execute 'syntax include @Guest syntax/'.a:guest.'.vim'
        execute 'syntax region GuestCode matchgroup=Snip start="'.a:start.'" end="'.a:end.'" containedin=@Host contains=@Guest'
        hi link Snip SpecialComment
    endfunction

    " }}}
    function! Itab(direction) abort "{{{
        " when pressing tab in insert mode...
        if pumvisible()
            if a:direction == 1 "without shift
                return "\<c-n>"
            else
                return "\<c-p>"
            endif
        else
            let col = col('.') - 1
            let is_not_at_end = !col || getline('.')[col - 1]  =~# '\s'
            if is_not_at_end
                return "\<tab>"
            else
                " completion
                call feedkeys("\<c-n>")
                call feedkeys("\<C-x>\<C-o>", "n")
                return ''
            endif
        endif
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
    function! Latexify(display) abort "{{{
        " convert to latex, requires pip install docal
python << EOF
import vim
from docal import eqn
from docal.handlers.latex import syntax
synt = syntax()
cline = vim.eval("getline('.')")
disp = False if int(vim.eval('a:display')) == 0 else True
txt, eq_asc = cline.rsplit('  ', 1) if '  ' in cline else ['', cline]
eq = eqn(eq_asc, disp=disp, syntax=synt).split('\n')
# "because they will be appended at the same line
eq.reverse()
vim.command(f"call setline('.', '{txt} {eq[-1]}')")
for e in eq[:-1]:
    vim.command(f"call append('.', '{e}')")
EOF
    endfunction

    " }}}
    function! Highlight() abort "{{{
        " override some highlights
        hi! link Folded Boolean
        hi! DiffChange guibg=#18384B
        hi! DiffDelete guifg=Grey
    endfunction

    " }}}
    function! ItemizeEnum() abort "{{{
        " automate itemize and enumerate in latex
        norm "xdipk
        let items = reverse(split(expand(@x), "\n"))
        let type = trim(items[-1]) == '.' ? 'enumerate' : 'itemize'
        if type == 'enumerate'
            let items = items[:-2]
        endif
        call append('.', '\end{'.type.'}')
        for i in items
            call append('.', '    \item '.i)
        endfor
        call append('.', '\setlength\itemsep{0pt}')
        call append('.', '\begin{'.type.'}')
        norm }
    endfunction

    " }}}
    function! InsertClipFigTex() abort "{{{
        " automate the saving to file and writing figure environments for
        " clipboard images to latex
        if &filetype == 'tex'
            let relpath = 'res'
            let imgpath = expand('%:h').'/'.relpath
            let ext = '.png'
            let fig_line = line('.')
            let line_split = split(getline(fig_line), '|', 1)
            let caption = trim(line_split[0])
            let label = len(line_split) > 1 ? trim(line_split[1]) : ''
            if exists('b:init_last_fig_pasted') && fig_line == b:init_last_fig_pasted[1] && filereadable(imgpath.'/'.b:init_last_fig_pasted[0].'.png')
                let imgname = b:init_last_fig_pasted[0]
                let img_write_success = 1
            else
                let imgname = strftime("%Y%m%d-%H%M%S")
                " this function is from md-img-paste.vim
                let img_write_success = !SaveFileTMP(imgpath, imgname)
                let b:init_last_fig_pasted = [imgname, fig_line]
            endif
            if img_write_success
                let include_ln = '\includegraphics[width=0.7\textwidth]{'.relpath.'/'.imgname.ext.'}'
                if len(caption) || len(label)
                    call setline('.', '\begin{figure} [ht]')
                    call append('.', '\end{figure}')
                    if len(label)
                        call append('.', '\label{'.label.'}')
                        let imgname = label.ext
                    endif
                    if len(caption)
                        call append('.', '\caption{'.caption.'}')
                    endif
                    call append('.', include_ln)
                else
                    call setline('.', include_ln)
                endif
            else
                echoerr 'Not an image or FS error'
            endif
        elseif &filetype == 'markdown'
            call mdip#MarkdownClipboardImage()
        else
            echoerr 'Not a tex file'
        endif
    endfunction

    " }}}
    function! PurgeUnusedImagesTex() abort "{{{
        " purge/delete unused images in the tex
        if &filetype == 'tex'
            let relpath = 'res'
            let imgpath = expand('%:h').'/'.relpath
            let imgs = split(glob(imgpath.'/*.png'), '\n')
            let deathrow = []
            for path in imgs
                let pattern = '\\includegraphics[^\n]*'.path[match(path, '\d\+-\d\+.png'):]
                if !search(pattern)
                    let deathrow += [path]
                endif
            endfor
            if len(deathrow)
                let prompt = "The following will be deleted.\n".join(deathrow, "\n")."\n\n(y/n): "
                let okay = input(prompt)
                if okay == 'y'
                    for path in deathrow
                        silent execute '!del' path
                    endfor
                endif
            endif
        endif
    endfunction

    " }}}
    function! MyFold(...) abort "{{{
        " better folding
        let other = a:0 ? '\|'.a:1 : ''
        let patt = &commentstring[:stridx(&commentstring, '%s')-1].'\|{{{'.other
        let fold_line = repeat('   ', v:foldlevel - 1) . ' ' . trim(substitute(getline(v:foldstart), patt, '', 'g'))
        return fold_line
        " }}}, keep the markers balanced
    endfunction

    " }}}
    function! LSPmaps() abort "{{{
        if index(['python', 'tex'], &filetype) == -1
            return
        endif
        " set completions
        setlocal omnifunc=v:lua.vim.lsp.omnifunc
        " define mappings
        nnoremap <buffer> <silent> <c-]> <cmd>lua vim.lsp.buf.declaration()<CR>
        nnoremap <buffer> <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
        nnoremap <buffer> <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
        nnoremap <buffer> <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
        nnoremap <buffer> <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
        nnoremap <buffer> <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
        nnoremap <buffer> <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
    endfunction

    " }}}

    "}}}
" SESSIONS: {{{

    " store globals as well for wintabs active positions
    set ssop=buffers,curdir
    "restore and resume commands with optional session names
    command! -nargs=? Resume call ResumeSession("<args>")
    command! -nargs=? Pause call SaveSession("<args>")

    "}}}
" PLUGINS: {{{

    "Management: {{{
        " managing func, lazy loads minpac first
        function! Pack() abort
            packadd minpac
            call minpac#init()
            call minpac#add('k-takata/minpac', {'type': 'opt'})
            call minpac#add('tpope/vim-commentary')
            call minpac#add('tpope/vim-surround')
            call minpac#add('lifepillar/vim-mucomplete')
            call minpac#add('neovim/nvim-lsp')
            call minpac#add('junegunn/fzf')
            call minpac#add('junegunn/fzf.vim')
            call minpac#add('jiangmiao/auto-pairs')
            call minpac#add('mhinz/vim-signify')
            call minpac#add('ryanoasis/vim-devicons')
            call minpac#add('mbbill/undotree')
            call minpac#add('mtth/scratch.vim')
            call minpac#add('liuchengxu/vista.vim')
            call minpac#add('michaeljsmith/vim-indent-object')
            call minpac#add('K1DV5/vim-code-dark')
            call minpac#add('ferrine/md-img-paste.vim')
            call minpac#add('mattn/emmet-vim', {'for': 'html'})
            call minpac#add('lambdalisue/gina.vim')
            call minpac#add('aserebryakov/vim-todo-lists')
            call minpac#add('justinmk/vim-sneak')
            call minpac#add('sheerun/vim-polyglot')
        endfunction

        " }}}
    "Mucomplete: {{{
        let g:mucomplete#enable_auto_at_startup = 1

        " }}}
    "Lsp: {{{
        function! LSP()
            " for texlab
            lua require 'nvim_lsp'.texlab.setup{}
            " for python
            lua require 'nvim_lsp'.pyls.setup{}
        endfunction

        " }}}
    "Devicons: {{{
        "folder icons
        let g:WebDevIconsUnicodeDecorateFolderNodes = 1
        let g:DevIconsEnableFoldersOpenClose = 1
        let g:DevIconsEnableFolderExtensionPatternMatching = 1

        " }}}
    "Tabs: {{{
        " tabs that are not normal buffers
        let g:tabs_custom_stl = {'gina-status': '%f', 'undo': '', 'vista': '', 'gina-commit': ''}

        " }}}
    "Python_syntax: {{{
        " enable all highlighting
        let g:python_highlight_all = 1
        let g:python_highlight_operators = 0
        let g:python_highlight_space_errors = 0
        let g:python_highlight_indent_errors = 0

        " }}}
    "Scratch: {{{
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
    "Term: {{{
        " set default shell to powershell
        let g:term_default_shell = 'powershell'

        " }}}
    "Signify: {{{
        " work only with git
        let g:signify_vcs_list = ['git']
        " show only colors
        let g:signify_sign_show_text = 0
        " hide numbers
        " let g:signify_sign_show_count = 0

        " }}}
    "Undotree: {{{
        " the layout
        let g:undotree_WindowLayout = 2
        " short timestamps
        let g:undotree_ShortIndicators = 1
        " width
        let g:undotree_SplitWidth = 29
        " autofocus
        let g:undotree_SetFocusWhenToggle = 1

        " }}}
    "Sneak: {{{
        " Make it like easymotion
        let g:sneak#label = 1
        "}}}
    " Vista: {{{
        " show definition in floating win
        let g:vista_echo_cursor_strategy = 'floating_win'
        " to use my own statusline
        let g:vista_disable_statusline = 1
        " }}}
    "Colorscheme: {{{
        if get(g:, 'colors_name', 'default') == 'default'
            " Use colors that suit a dark background
            set background=dark
            " Change colorscheme
            colorscheme codedark
        endif

        " }}}

    "}}}
" AUTOCOMMANDS: {{{
    " define in an autogroup for re-sourcing
    augroup init
        autocmd!
        "resume session, override some colors
        autocmd VimEnter * nested call EntArgs('enter') | call Highlight()
        "save session
        autocmd VimLeavePre * call EntArgs('leave')
        " save the current window number before jumping to jump back
        autocmd WinLeave * let g:init_alt_win = win_getid()
        " highlight where lines should end and map for inline equations for latex
        autocmd FileType tex setlocal colorcolumn=80 spell | inoremap <buffer> <c-space> <esc><cmd>call Latexify(0)<cr>A
        " lsp completions
        autocmd FileType * call LSPmaps()
        " use emmet for html
        autocmd FileType html,php inoremap <c-space> <cmd>call emmet#expandAbbr(0, "")<cr><right>
        " gc: edit commit message, gp: push, <cr>: commit
        autocmd FileType gina-status noremap <buffer> gc <cmd>Gina commit<cr> | noremap <buffer> gp <cmd>Gina push<cr>
        autocmd FileType gina-commit inoremap <buffer> <cr> <esc><cmd>wq<cr>
        " use o to open definition
        autocmd FileType vista nmap <buffer> o <enter> | nmap <buffer> <2-LeftMouse> <enter>
        " close tags window when help opens
        autocmd BufWinEnter *.txt if &buftype == 'help'
            \| wincmd L
            \| execute 'vertical resize' &columns/2
            \| silent! execute 'Vista!'
            \| endif
    augroup END

    "}}}

" vim:foldmethod=marker:foldlevel=0:foldtext=MyFold('\:')
