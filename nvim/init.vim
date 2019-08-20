" K1DV5 - nvimrc
" https://github.com/K1DV5/nvimrc
" Released under the MIT License

"----------------------------------------------------------------
"CONTENTS: (jump there using "*")

    "C_BUILTINS
        "S_miscellaneous
        "S_performance

    "C_PLUGINS (Use this macro at the top of config titles):
            " jyygg/C_PLUGIN}P>>$x€kb€kb€kb}
        "S_management
        "S_ale
        "S_airline
        "S_devicons
        "S_nerdtree
        "S_wintabs
        "S_tagbar
        "S_python_syntax
        "S_scratch
        "S_term
        "S_autopairs
        "S_FZF
        "S_sneak
        "S_signify
        "S_colorscheme

    "C_FUNCTIONS
    "C_SESSIONS
    "C_MAPPINGS
        "S_normal_mode
        "S_insert_mode
        "S_visual_mode
        "S_with_leader_key
            "SS_linting

    "C_AUTOCOMMANDS
"----------------------------------------------------------------

"C_BUILTINS:

    "S_miscellaneous:
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
        let $MYGVIMRC = "C:/Users/Kidus\ III/AppData/Local/nvim/ginit.vim"
        " keep windows the same size when adding/removing
        set noequalalways
        " hide the ~'s at the end of files
        set fillchars=eob:\ ,diff:\  "make it disappear
        " keep some lines visible at top/bottom when scrolling
        set scrolloff=3
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

    "S_performance:
        " hide buffers when not shown in window
        set hidden
        " Donâ€™t update screen during macro and script execution
        set lazyredraw
        " disable python 2
        " let g:loaded_python_provider = 1
        " disable ruby
        let g:loaded_ruby_provider = 1
        " disable node.js
        let g:loaded_node_provider = 1
        " set python path
        let g:python3_host_prog = 'D:\K1DV5\DevPrograms\Python\python'
        let g:python_host_prog = 'D:\K1DV5\DevPrograms\Python\python'
        " disable builtin plugins
        let g:loaded_gzip = 1
        let g:loaded_zipPlugin = 1
        let g:loaded_2html_plugin = 1
        let g:loaded_tarPlugin = 1


"C_PLUGINS:

    "S_management:
        call plug#begin()
        Plug 'tpope/vim-commentary'
        Plug 'tpope/vim-surround'
        Plug 'neoclide/coc.nvim', {'branch': 'release'}
        Plug 'Shougo/context_filetype.vim'
        Plug 'mhinz/vim-signify'
        Plug 'tpope/vim-fugitive', {'on': 'Gstatus'}
        Plug 'vim-python/python-syntax', {'for': 'python'}
        Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
        Plug 'vim-airline/vim-airline'
        Plug 'ryanoasis/vim-devicons'
        Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
        Plug 'D:/K1DV5/Documents/Code/.dotfiles/nvim/terminal-pane'
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
        call plug#end()

    "S_coc:
        let g:coc_snippet_next = '<tab>'

    "S_airline:
        "show tab line at top
        let g:airline#extensions#tabline#enabled = 1
        "use devicons/powerline fonts (airline)
        let g:airline_powerline_fonts = 1
        " make label areas rectangular
        let g:airline_left_sep=''
        let g:airline_right_sep=''
        let g:airline_left_alt_sep = '|'
        let g:airline_right_alt_sep = '|'

    "S_devicons:
        "folder icons
        let g:WebDevIconsUnicodeDecorateFolderNodes = 1
        let g:DevIconsEnableFoldersOpenClose = 1
        let g:DevIconsEnableFolderExtensionPatternMatching = 1

    "S_nerdtree:
        " remove "press ... for help"
        let g:NERDTreeMinimalUI = 1
        " Improve NERDTree arrow
        let g:NERDTreeDirArrowCollapsible="ï‘¼"
        " Improve NERDTree arrow
        let g:NERDTreeDirArrowExpandable="ï‘ "
        " quit nerdtree when opening file
        " let g:NERDTreeQuitOnOpen = 1
        " Show hidden files on NERDTree
        let g:NERDTreeShowHidden = 1
        let g:NERDTreeShowGitStatus = 1
        let g:NERDTreeUpdateOnWrite = 1

    "S_wintabs:
        " also contains wintabs powerline
        " customize tabline buffers separators
        let g:wintabs_powerline_sep_buffer_transition = " "
        let g:wintabs_powerline_sep_buffer = "|"
        " let g:wintabs_powerline_sep_vimtab_transition = " "
        " let g:wintabs_powerline_sep_vimtab = "|"
        " change the buffer labels
        let g:wintabs_ui_buffer_name_format = " %o %t "

    "S_tagbar:
        " zoom as much as needed for full tag display
        let g:tagbar_zoomwidth = 0
        " open and closed tags indicators
        let g:tagbar_iconchars = ['ï‘ ', 'ï‘¼']
        " sort by appearance order
        let g:tagbar_sort = 0

    "S_python_syntax:
        " enable all highlighting
        let g:python_highlight_all = 1
        let g:python_highlight_operators = 0
        let g:python_highlight_space_errors = 0
        let g:python_highlight_indent_errors = 0

    "S_scratch:
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

    "S_term:
        " set default shell to powershell
        let g:term_default_shell = 'powershell'

    "S_autopairs:
        "disable the next pair map
        let g:AutoPairsShortcutJump = '<M-p>'

    "S_FZF:
        " split just below the current buffer
        let g:fzf_layout = { 'window': 'bel 12split enew' }
        " Customize fzf colors to match the color scheme
        let g:fzf_colors =
        \ { 'fg':      ['fg', 'Normal'],
        \ 'bg':      ['bg', 'Normal'],
        \ 'hl':      ['fg', 'Comment'],
        \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
        \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
        \ 'hl+':     ['fg', 'Statement'],
        \ 'info':    ['fg', 'PreProc'],
        \ 'border':  ['fg', 'Ignore'],
        \ 'prompt':  ['fg', 'Conditional'],
        \ 'pointer': ['fg', 'Exception'],
        \ 'marker':  ['fg', 'Keyword'],
        \ 'spinner': ['fg', 'Label'],
        \ 'header':  ['fg', 'Comment'] }

    "S_signify:
        " work only with git
        let g:signify_vcs_list = ['git']
        " show only colors
        let g:signify_sign_show_text = 0
        " hide numbers
        " let g:signify_sign_show_count = 0

    "S_colorscheme:
        " Use colors that suit a dark background
        set background=dark
        " Change colorscheme
        colorscheme codedark

"C_FUNCTIONS:

    " to resume a session
    function! ResumeSession(file)
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

    " to save a session
    function! SaveSession(file)
        if a:file == ""
            let l:session_file = '~/AppData/Local/nvim/Session'
        else
            let l:session_file = a:file
        endif
        execute 'mksession!' fnameescape(l:session_file.'.vim')
    endfunction

    " delete all terminal buffers
    function! DelTerms()
        if bufname('%') =~ '^term://'
            bdelete!
        else
            let l:terms = filter(copy(nvim_list_bufs()), 'bufname(v:val) =~ "^term://"')
            if len(l:terms) > 0
                execute 'bdelete!' join(l:terms)
            endif
        endif
    endfunction

    " what to do at startup
    function! EntArgs(event)
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
            endif
        endif
    endfunction

    " auto figure out what to do
    function! Please_Do()
        wincmd k
        let s:ext_part = expand('%:e')
        silent update!
        let l:hidden = ['tex', 'texw', 'ahk', 'html', 'htm', 'md', 'pmd']
        let l:cwd = getcwd()
        cd %:h
        if index(l:hidden, s:ext_part) != -1
            setlocal makeprg=python\ D:\\K1DV5\\Documents\\Code\\.dotfiles\\misc\\do.py
            execute 'make' substitute('"'.expand('%:p').'"', 'Kidus III', 'K1DV5', 'g')
            echo "Done."
        else
            call Term('python D:/K1DV5/Documents/Code/.dotfiles/misc/do.py '.expand('%:t'))
            norm i
        endif
        execute 'cd' l:cwd
    endfunction

    " switch buffers without collateral damage
    function! SwitchTaB(where)
        if &filetype == 'nerdtree'
            NERDTreeClose
        endif
        " location before jump
        let temp_alt = bufnr('%')
        if a:where == 0
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

    " switch windows, works with autocmd WinLeave to save the win id
    function! SwitchWin() abort
        " let temp_alt_win = win_getid()
        if !(exists('g:init_alt_win') && win_getid() != g:init_alt_win && win_gotoid(g:init_alt_win))
            execute "norm! \<c-w>w"
        endif
        " let g:init_alt_win = temp_alt_win
    endfunction

    " substitute in visual selection
    function! Subs(where) abort
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

    " show git status
    function! GitStat()
        if &filetype == 'gitcommit' || &filetype == 'fugitive'
            wincmd c
        else
            try
                Gstatus
            catch
                edit
                Gstatus
            endtry
        endif
    endfunction

    " open outline view (if supported)
    function! Outline() abort
        let l:bufname = expand('%')
        if l:bufname =~ 'contents.*vimtex'
            hide
        elseif expand('%:e') == 'tex' || expand('%:e') == 'texw'
            VimtexTocOpen
        endif
    endfunction

    " follow help links with enter
    function! CRFunc() abort
        let l:supported = ['vim', 'help', 'python']
        if index(l:supported, &filetype) != -1
            norm K
        else
            execute "norm! \<cr>"
        endif
    endfunction

    " Syntax highlighting based on the context range (modified from
    " brotchie/python-sty)
    function! ContextSyntax(host, guest, start, end)
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

    " when pressing tab in insert mode...
    function! Itab(direction) abort
        if pumvisible()
            if a:direction == 1 "without shift
                " call coc#_select_confirm()
                return "\<c-n>"
            else
                return "\<c-p>"
            endif
        " elseif coc#expandableOrJumpable()
        "     return "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" 
        else
            return "\<tab>"
        endif
    endfunction
	function! s:check_back_space() abort
	  let col = col('.') - 1
	  return !col || getline('.')[col - 1]  =~# '\s'
	endfunction

    " NERDTree jumping and closing
    function! NERDhandle(toggle) abort
        if a:toggle
            NERDTreeToggle
        else
            let l:nerd_bufwins = filter(copy(nvim_list_wins()), 'bufname(winbufnr(v:val)) =~ "^NERD_tree_"')
            if l:nerd_bufwins != []
                if bufname(@%) =~ '^NERD_tree_'
                    call win_gotoid(1000)
                else
                    call win_gotoid(l:nerd_bufwins[0])
                endif
            else
                NERDTree
            endif
        endif
    endfunction

    python import vim
    python from docal import eqn
    function! Latexify(display) abort
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

    " automate itemize and enumerate in latex
    function! ItemizeEnum() abort
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

    " automate the saving to file and writing figure environments for
    " clipboard images to latex
    function! InsertClipFigTex() abort
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

    " purge/delete unused images in the tex
    function! PurgeUnusedImagesTex() abort
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

    " LSP mappings
    function! LSP()
        let l:filetypes = ['python', 'css', 'html', 'json', 'js']
        if index(l:filetypes, &filetype) != -1
            nmap <buffer> gd <Plug>(coc-definition)
            nmap <buffer> <f2> <Plug>(coc-rename)
            nmap <buffer> gm <Plug>(coc-references)
            noremap <buffer> gh <cmd>call CocAction('doHover')<enter>
            " augroup Hover
            "     autocmd!
            "     autocmd CursorHold <buffer> nested call CocActionAsync("doHover")
            "     " autocmd CursorMoved <buffer> nested pclose
            " augroup END
        endif
    endfunction

"C_SESSIONS:

    " when working with sessions, do not store global and local values and folds
    set ssop=buffers,curdir,globals,tabpages
    " disable other options if wanted
    command! NoSaveSession set ssop=buffers,curdir
    "restore and resume commands with optional session names
    command! -nargs=? Resume call ResumeSession("<args>")
    command! -nargs=? Pause call SaveSession("<args>")

"C_MAPPINGS:

    "S_normal_mode:
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
        " for sneak
        " map f <Plug>Sneak_s
        " map F <Plug>Sneak_S

    "S_command_mode:
        " paste on command line
        cnoremap <c-v> <c-r>*
        cnoremap <c-h> <cmd>norm h<cr>
        cnoremap <c-j> <cmd>norm gj<cr>
        cnoremap <c-k> <cmd>norm gk<cr>
        cnoremap <c-l> <cmd>norm l<cr>
        " go normal
        cnoremap kj <esc>

    "S_insert_mode:
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
        " confirm completion
        inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

    "S_visual_mode:
        " escape quick
        vnoremap kj <esc>
        vnoremap KJ <esc>
        " search for selected text
        vnoremap // y/<c-r>"<cr>
        " change all instances of selected text
        vnoremap /c <cmd>call Subs('all')<cr>
        " change something in current selection (sep by double space)
        vnoremap /w <cmd>call Subs('within')<cr>

    "S_with_leader_key:
        let mapleader = ','
        " show git status
        noremap <leader>g <cmd>call GitStat()<cr>
        " open outline view (if supported)
        nmap <leader>o <cmd>call Outline()<cr>
        " open terminal pane
        noremap <leader>t <cmd>call SwitchTerm(0.3)<cr>
        " closing current buffer
        noremap <leader>bb <cmd>WintabsClose<cr>
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

        "SS_clipboard:
            " use system clipboard
            noremap <leader>c "+

"C_AUTOCOMMANDS:

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
        autocmd FileType tex setlocal colorcolumn=80 spell | inoremap <c-space> <esc><cmd>call Latexify(0)<cr>A
        " close tagbar when help opens
        autocmd BufWinEnter *.txt if &buftype == 'help'
            \| wincmd L
            \| silent! execute 'TagbarClose'
            \| execute 'vertical resize' &columns/2
            \| endif
        " remove line numbers from the terminal windows
        autocmd TermOpen * setlocal nonumber norelativenumber
        " change the line numbers based on mode
        autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &modifiable | set relativenumber | endif
        autocmd BufLeave,FocusLost,InsertEnter,WinLeave * if &modifiable | set norelativenumber | endif
        " set lsp mappings for supported filetypes
        autocmd FileType * call LSP()
        " wipeout netrw buffers when hidden
        autocmd FileType netrw setlocal bufhidden=wipe
    augroup END

