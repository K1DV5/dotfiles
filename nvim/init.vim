" K1DV5 - nvimrc
" https://github.com/K1DV5/nvimrc
" Released under the MIT License

" C_BUILTINS: {{{

    "S_miscellaneous: {{{
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
        set number
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
        set fillchars=eob:\ ,diff:\ ,fold:\  "make it disappear
        " keep some lines visible at top/bottom when scrolling
        " set scrolloff=3
        " read only the first and last lines
        set modelines=1
        "print info on cmdline
        set noshowmode
        "disable the preview window when in completion
        set completeopt-=preview
        "always have a space for gutter signs (on the left of the line numbers)
        set signcolumn=yes
        " show diff with vertical split
        set diffopt+=vertical
        " some filetype specific features
        filetype plugin indent on
        " default sql variant
        let g:sql_type_default = 'mysql'
        " fold text
        set foldtext=MyFold()
        " allow expressions in modelines
        set modelineexpr
        "}}}

    "S_performance: {{{
        " hide buffers when not shown in window
        set hidden
        " Don’t update screen during macro and script execution
        set lazyredraw
        " disable python 2
        " let g:loaded_python_provider = 1
        " disable ruby
        let g:loaded_ruby_provider = 1
        " disable node.js
        let g:loaded_node_provider = 1
        " set python path
        let g:python3_host_prog = 'D:\DevPrograms\Python\python'
        let g:python_host_prog = 'D:\DevPrograms\Python\python'
        " disable builtin plugins
        let g:loaded_gzip = 1
        let g:loaded_zipPlugin = 1
        let g:loaded_2html_plugin = 1
        let g:loaded_tarPlugin = 1
        let loaded_netrwPlugin = 1
        "}}}

    "}}}

" C_PLUGINS: {{{

    "S_management: {{{
        call plug#begin()
        Plug 'tpope/vim-commentary'
        Plug 'tpope/vim-surround'
        Plug 'neoclide/coc.nvim', {'branch': 'release'}
        Plug 'Shougo/context_filetype.vim'
        " Plug 'mhinz/vim-signify'
        Plug 'tpope/vim-fugitive'
        Plug 'vim-python/python-syntax', {'for': 'python'}
        Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
        " Plug 'Xuyuanp/nerdtree-git-plugin'
        Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
        Plug 'vim-airline/vim-airline'
        Plug 'ryanoasis/vim-devicons'
        Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
        Plug stdpath('config').'/terminal-pane'
        Plug 'mtth/scratch.vim'
        Plug 'majutsushi/tagbar', {'on': 'TagbarToggle'}
        Plug 'zefei/vim-wintabs'
        Plug 'zefei/vim-wintabs-powerline'
        Plug 'othree/html5.vim', {'for': 'html'}
        Plug 'michaeljsmith/vim-indent-object'
        Plug 'K1DV5/vim-code-dark'
        Plug 'ferrine/md-img-paste.vim'
        Plug 'pangloss/vim-javascript'
        Plug 'mxw/vim-jsx'
        Plug 'StanAngeloff/php.vim'
        Plug 'mattn/emmet-vim'
        Plug 'mustache/vim-mustache-handlebars'
        " Plug 'lambdalisue/gina.vim'
        Plug 'aserebryakov/vim-todo-lists'
        call plug#end()
        " }}}

    "S_coc: {{{
        let g:coc_snippet_next = '<tab>'
        call coc#add_extension('coc-json', 'coc-tsserver', 'coc-html', 'coc-pairs', 'coc-css', 'coc-python', 'coc-powershell', 'coc-texlab')
        " }}}

    "S_airline: {{{
        "show tab line at top
        let g:airline#extensions#tabline#enabled = 1
        " show git info
        let g:airline#extensions#branch#enabled = 1
        "use devicons/powerline fonts (airline)
        let g:airline_powerline_fonts = 1
        " make label areas rectangular
        let g:airline_left_sep=''
        let g:airline_right_sep=''
        let g:airline_left_alt_sep = '|'
        let g:airline_right_alt_sep = '|'
        " }}}

    "S_devicons: {{{
        "folder icons
        let g:WebDevIconsUnicodeDecorateFolderNodes = 1
        let g:DevIconsEnableFoldersOpenClose = 1
        let g:DevIconsEnableFolderExtensionPatternMatching = 1
        " }}}

    "S_nerdtree: {{{
        " remove "press ... for help"
        let g:NERDTreeMinimalUI = 1
        " Improve NERDTree arrow
        let g:NERDTreeDirArrowCollapsible=""
        " Improve NERDTree arrow
        let g:NERDTreeDirArrowExpandable=""
        " quit nerdtree when opening file
        " let g:NERDTreeQuitOnOpen = 1
        " Show hidden files on NERDTree
        let g:NERDTreeShowHidden = 1
        let g:NERDTreeShowGitStatus = 1
        let g:NERDTreeUpdateOnWrite = 1
        " }}}

    "S_wintabs: {{{
        " also contains wintabs powerline
        " customize tabline buffers separators
        let g:wintabs_powerline_sep_buffer_transition = " "
        let g:wintabs_powerline_sep_buffer = "|"
        " let g:wintabs_powerline_sep_vimtab_transition = " "
        " let g:wintabs_powerline_sep_vimtab = "|"
        " change the buffer labels
        let g:wintabs_ui_buffer_name_format = " %o %t "
        " }}}

    "S_tagbar: {{{
        " zoom as much as needed for full tag display
        let g:tagbar_zoomwidth = 0
        " open and closed tags indicators
        let g:tagbar_iconchars = ['', '']
        " sort by appearance order
        let g:tagbar_sort = 0
        " }}}

    "S_python_syntax: {{{
        " enable all highlighting
        let g:python_highlight_all = 1
        let g:python_highlight_operators = 0
        let g:python_highlight_space_errors = 0
        let g:python_highlight_indent_errors = 0
        " }}}

    "S_scratch: {{{
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

    "S_term: {{{
        " set default shell to powershell
        let g:term_default_shell = 'powershell'
        " }}}

    "S_signify: {{{
        " work only with git
        let g:signify_vcs_list = ['git']
        " show only colors
        let g:signify_sign_show_text = 0
        " hide numbers
        " let g:signify_sign_show_count = 0
        " }}}

    "S_undotree: {{{
        " the layout
        let g:undotree_WindowLayout = 3
        " short timestamps
        let g:undotree_ShortIndicators = 1
        " width
        let g:undotree_SplitWidth = 29
        " autofocus
        let g:undotree_SetFocusWhenToggle = 1
        " }}}

    "S_colorscheme: {{{
        " Use colors that suit a dark background
        set background=dark
        " Change colorscheme
        colorscheme codedark
        " }}}

    "}}}

" C_FUNCTIONS: {{{

    function! ResumeSession(file) "{{{
        " to resume a session
        if a:file == ""
            let l:session_file = '~/AppData/Local/nvim/Session'
        else
            let l:session_file = a:file
        endif
        try
            silent execute 'source' fnameescape(l:session_file.'.vim')
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
        execute 'mksession!' fnameescape(l:session_file.'.vim')
    endfunction
    " }}}

    function! EntArgs(event) "{{{
        " what to do at startup, and exit
        if a:event == 'enter'
            if argc() == 0
                call ResumeSession('')
                WintabsAllBuffers
                CocEnable
            else
                execute 'cd' expand('%:p:h')
                WintabsAllBuffers
                if bufname('%') == ''
                    bdelete
                endif
            endif
        else
            if argc() == 0
                silent call DelTerms()
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
        let l:hidden = ['tex', 'texw', 'html', 'htm', 'md', 'pmd']
        let l:cwd = getcwd()
        cd %:h
        let script = 'D:/Documents/Code/.dotfiles/misc/do.py'
        if index(l:hidden, s:ext_part) != -1
            execute 'setlocal makeprg=python' script
            execute 'make' expand('%:p')
            echo "Done."
        else
            call Term('python '.script.' '.expand('%:t'))
            norm i
        endif
        execute 'cd' l:cwd
    endfunction
    " }}}

    function! SwitchTaB(where) "{{{
        " switch buffers without collateral damage
        if &filetype == 'nerdtree'
            NERDTreeClose
        endif
        " location before jump
        let temp_alt = bufnr('%')
        if a:where == 0 && exists('w:alt_file')
            " stored by this func
            let alt_file_index = index(w:wintabs_buflist, w:alt_file)
            " stored by vim
            let alt_hash_index = index(w:wintabs_buflist, bufnr('#'))
            if exists('w:alt_file') && alt_file_index != -1 && w:alt_file != temp_alt
                execute 'WintabsGo' 1 + alt_file_index
            elseif alt_hash_index != -1
                execute 'WintabsGo' 1 + alt_hash_index
            else
                WintabsNext
            endif
        elseif a:where > 0
            execute 'WintabsGo' a:where
        else
            WintabsNext
        endif
        let w:alt_file = temp_alt
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
        if &filetype == 'gitcommit' || &filetype == 'fugitive'
            let l:to_be_closed = bufnr()
            call win_gotoid(1000)
            execute 'bdelete' l:to_be_closed
        else
            try
                Gstatus
            catch
                edit
                Gstatus
            endtry
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
                " call coc#_select_confirm()
                return "\<c-n>"
            else
                return "\<c-p>"
            endif
        else
            return "\<tab>"
        endif
    endfunction
    function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
    endfunction
    " }}}

    function! NERDhandle(toggle) abort "{{{
        " NERDTree jumping and closing
        if a:toggle
            NERDTreeToggle
        else
            let l:nerd_bufwins = filter(copy(nvim_list_wins()), 'bufname(winbufnr(v:val)) =~ "^NERD_tree_"')
            if l:nerd_bufwins != []
                if &filetype == 'nerdtree'
                    execute "norm \<c-w>l"
                else
                    call win_gotoid(l:nerd_bufwins[0])
                endif
            else
                NERDTree
            endif
        endif
    endfunction
    " }}}

    function! Latexify(display) abort "{{{
        " convert to latex, requires pip install docal
python import vim
python from docal import eqn
python << EOF
cline = vim.eval("getline('.')")
disp = False if int(vim.eval('a:display')) == 0 else True
txt, eq_asc = cline.rsplit('  ', 1) if '  ' in cline else ['', cline]
eq = eqn(eq_asc, disp=disp).split('\n')
# "because they will be appended at the same line
eq.reverse()
vim.command(f"call setline('.', '{txt} {eq[-1]}')")
for e in eq[:-1]:
    vim.command(f"call append('.', '{e}')")
EOF
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

    function! LSP() abort "{{{
        " LSP mappings
        let l:filetypes = ['python', 'css', 'html', 'json', 'js', 'javascript.jsx']
        if index(l:filetypes, &filetype) != -1
            nmap <buffer> gd <Plug>(coc-definition)
            nmap <buffer> <f2> <Plug>(coc-rename)
            nmap <buffer> gm <Plug>(coc-references)
            nmap <buffer> <expr> K CocActionAsync('doHover')
            noremap <buffer> gh <cmd>call CocAction('doHover')<enter>
            setlocal formatexpr=CocAction('formatSelected')
            " augroup Hover
            "     autocmd!
            "     autocmd CursorHold <buffer> nested call CocActionAsync("doHover")
            "     " autocmd CursorMoved <buffer> nested pclose
            " augroup END
        endif
    endfunction
    " }}}

    function! GridNav() abort "{{{
        " navigate using the keyboard as grid copy of the screen
        let rows = ['1234567890-=', 'qwertyuiop[]', 'asdfghjkl;', 'zxcvbnm,./']
        let char = nr2char(getchar())
        let char = char == '"'? '\\"': char
        let row = filter(copy(rows), 'stridx(v:val, "'.char.'") != -1')[0]
        " vertical fraction
        let fline = index(rows, row)*1.0 / len(rows)
        let theight = &lines - &lines / len(rows)
        let lines = theight*1.0/len(rows) + theight
        let line = &lines / (len(rows) * 2) + float2nr(round(lines*fline))
        " horizontal fraction
        let fcol = stridx(row, char)*1.0 / len(row)
        let twidth = &columns - &columns / len(row)
        let cols = twidth*1.0/len(row) + twidth
        let col = &columns / (len(row) * 2) + float2nr(round(cols*fcol))
        " find the win
        let wins = nvim_list_wins()
        for winid in wins
            let winheight = nvim_win_get_height(winid)
            let winwidth = nvim_win_get_width(winid)
            let pos = nvim_win_get_position(winid)
            if pos[0] <= (line + 1) && (line + 1) <= (pos[0] + winheight) && pos[1] <= (col + 2) && (col + 2) <= (pos[1] + winwidth)
                break
            endif
        endfor
        call win_gotoid(winid)
        norm H
        let line = line('.') + line - pos[0]
        let col = col - pos[1]
        call cursor(line, col)
        echo 'line: '.line.', col: '.col
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

    "}}}

" C_SESSIONS: {{{

    " store globals as well for wintabs active positions
    set ssop=buffers,curdir,globals
    "restore and resume commands with optional session names
    command! -nargs=? Resume call ResumeSession("<args>")
    command! -nargs=? Pause call SaveSession("<args>")
    "}}}

" C_MAPPINGS: {{{

    "S_normal_mode: {{{
        " do what needs to be done
        noremap <c-p> <cmd>call Please_Do()<cr>
        " move lines up down
        noremap <a-k> <cmd>move-2<cr>
        noremap <a-j> <cmd>move+1<cr>
        "scroll by space and [shift] space
        noremap <space> <c-f>
        noremap <s-space> <c-b>
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
        noremap <tab> <cmd>call SwitchTaB(0)<cr>
        noremap <s-tab> <cmd>call SwitchTaB(-1)<cr>
        " to return to normal mode in terminal
        tnoremap kj <C-\><C-n>
        " do the same thing as normal mode in terminal for do
        tnoremap <c-p> <C-\><C-n><cmd>call Please_Do()<cr>
        " toggle nerdtree
        noremap <s-a-n> <cmd>call NERDhandle(1)<cr>
        noremap <a-n> <cmd>call NERDhandle(0)<cr>
        " lookup help for something under cursor with enter
        nnoremap <cr> <cmd>call CRFunc()<cr>
        " go back with [shift] backspace
        nnoremap <bs> <esc><c-o>
        nnoremap <s-bs> <esc><c-i>
        " toggle tagbar
        noremap <c-t> <cmd>TagbarToggle<cr>
        " window navigation
        noremap s <cmd>call GridNav()<cr>
        "}}}

    "S_command_mode: {{{
        " paste on command line
        cnoremap <c-v> <c-r>*
        cnoremap <c-h> <cmd>norm h<cr>
        cnoremap <c-j> <cmd>norm gj<cr>
        cnoremap <c-k> <cmd>norm gk<cr>
        cnoremap <c-l> <cmd>norm l<cr>
        " go normal
        cnoremap kj <esc>
        "}}}

    "S_insert_mode: {{{
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
        " go through suggestions or jump to snippet placeholders
        imap <expr> <tab> Itab(1)
        imap <expr> <s-tab> Itab(0)
        smap <expr> <tab> Itab(0)
        " refresh completion
        inoremap <silent><expr> <c-space> coc#refresh()
        "}}}

    "S_visual_mode: {{{
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

    "S_with_leader_key: {{{
        let mapleader = ','
        " show git status
        noremap <leader>g <cmd>call GitStat()<cr>
        " open terminal pane
        noremap <leader>t <cmd>call Term(0.3)<cr>
        tnoremap <leader>t <cmd>call Term(0.3)<cr>
        " open big terminal window
        noremap <leader>T <cmd>call Term(1)<cr>
        " closing current buffer
        noremap <expr> <leader>bb &buftype == 'terminal'? '<cmd>call DelTerms()<cr>' : '<cmd>WintabsClose<cr>'
        tnoremap <leader>bb <cmd>call DelTerms()<cr>
        " save file if changed and source if it is a vim file
        noremap <expr> <leader>bu &filetype == 'vim' ? '<cmd>update! \| source %<cr>' : '<cmd>update!<cr>'
        " delete terminal buffers
        noremap <leader>bt <cmd>call DelTerms()<cr>
        " toggle spell check
        noremap <leader>z <cmd>setlocal spell! spelllang=en_us<cr>
        " quit
        noremap <leader><esc> <cmd>xall!<cr>
        " undotree
        noremap <leader>u <cmd>UndotreeToggle<cr>
        " enter window commands
        noremap <leader>w <c-w>
        " fuzzyfind files and other things
        noremap <expr> <leader>f &modifiable ? '<cmd>FZF<cr>' : ''
        noremap <expr> <leader>F &modifiable ? '<cmd>FZF ~/Documents<cr>' : ''
        " undo wintabs command
        noremap <leader>wu <Plug>(wintabs_undo)
        " jump directly to {n}th wintab
        noremap <leader>1 <cmd>call SwitchTaB(1)<cr>
        noremap <leader>2 <cmd>call SwitchTaB(2)<cr>
        noremap <leader>3 <cmd>call SwitchTaB(3)<cr>
        noremap <leader>4 <cmd>call SwitchTaB(4)<cr>
        noremap <leader>5 <cmd>call SwitchTaB(5)<cr>
        noremap <leader>6 <cmd>call SwitchTaB(6)<cr>
        noremap <leader>7 <cmd>call SwitchTaB(7)<cr>
        noremap <leader>8 <cmd>call SwitchTaB(8)<cr>
        noremap <leader>9 <cmd>call SwitchTaB(9)<cr>
        noremap <leader>0 <cmd>call SwitchTaB(10)<cr>
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
        "}}}
    "}}}

" C_AUTOCOMMANDS: {{{

    " define in an autogroup for re-sourcing
    augroup theautocmds
        autocmd!
        "resume session, open the tags panel
        autocmd VimEnter * nested call EntArgs('enter')
        "save session
        autocmd VimLeavePre * call EntArgs('leave')
        " close preview window
        autocmd InsertLeave * silent! pclose!
        "save the buffer number for switching back easily
        autocmd BufNewFile,BufRead * let w:alt_file = bufnr('#')
        " save the current window number before jumping to jump back
        autocmd WinLeave * let g:init_alt_win = win_getid()
        " highlight 78th column for python files
        autocmd FileType python setlocal colorcolumn=79 omnifunc=python3complete#Complete formatprg=autopep8\ -
        " highlight where lines should end and map for inline equations for latex
        autocmd FileType tex setlocal colorcolumn=80 spell | inoremap <buffer> <c-space> <esc><cmd>call Latexify(0)<cr>A
        " use emmet for html
        autocmd FileType html,php inoremap <c-space> <cmd>call emmet#expandAbbr(0, "")<cr><right>
        " close tagbar when help opens
        autocmd BufWinEnter *.txt if &buftype == 'help'
            \| wincmd L
            \| silent! execute 'TagbarClose'
            \| execute 'vertical resize' &columns/2
            \| endif
        " remove line numbers from the terminal windows and offsets
        autocmd TermOpen * setlocal nonumber norelativenumber nowrap
        " set lsp mappings for supported filetypes
        autocmd FileType * call LSP()
        " wipeout netrw buffers when hidden
        autocmd FileType netrw setlocal bufhidden=wipe
    augroup END

    "}}}

" C_OVERRIDES: {{{
    " change the highlighting
    hi! link Folded Boolean
    hi! link FoldColumn Boolean
    "}}}

" vim:foldmethod=marker:foldlevel=0:foldcolumn=3:foldtext=MyFold('\:')
