" term-pane plugin
" Written by K1DV5
" depends on zefei/vim-wintabs
"
" Constant(s):
let s:default_shell = exists('term_default_shell')? g:term_default_shell : &shell

" define command
command! -nargs=? T call Term("<args>")

function! s:TermHeight(size) abort
	" if the size is less than 1, it will be taken as the fraction of the file
	" window
	if a:size > 1
		let l:term_height = a:size
	else
		if &buftype == 'terminal'
			let l:alt_window_id = nvim_list_wins()[index(nvim_list_wins(), bufwinid(@%)) - 1]
			let l:term_height = float2nr((winheight(l:alt_window_id) + winheight(0) + 1) * a:size)
		else
			let l:term_height = float2nr(winheight(0) * a:size) 
		endif
	endif	
	return l:term_height
endfunction

" find and go to terminal pane, return success
function! s:GoToTerm() abort
	" terminal windows
	let l:tbufwins = filter(copy(nvim_list_wins()), 'getbufvar(winbufnr(v:val), "&buftype") == "terminal"')
    " if there is a terminal window
    if l:tbufwins != []
        " go to that window
        call win_gotoid(l:tbufwins[0])
        return 1
    endif
    return 0
endfunction

function! s:ToggleTerm(size) abort
    " a:size - number | float - the desired size of the pane
	" work only if buffer is a normal file
	if !buflisted(@%)
        echo "Not a file buffer, aborting..."
		return
	endif
	let l:term_height = s:TermHeight(a:size)
	" if in terminal pane
	if &buftype == 'terminal'
		if winheight(0) < l:term_height " maximize
			execute 'resize' l:term_height
		else
			let g:term_current_buf = bufnr('%')
			hide
		endif
	else
        if !s:GoToTerm()
            " terminal buffers
            let l:tbuflist = filter(copy(nvim_list_bufs()), 'getbufvar(v:val, "&buftype") == "terminal"')
            " if last opened terminal is hidden but exists
            if exists('g:term_current_buf') && buflisted(g:term_current_buf)
                execute 'belowright' l:term_height.'split +buffer\' g:term_current_buf
            elseif len(l:tbuflist) " choose one of the others
                execute 'belowright' l:term_height.'split +buffer\' l:tbuflist[0]
            else " create a new one
                execute 'belowright' l:term_height.'split term://'.s:default_shell
            endif
            " bring other terminal buffers into this window
            let w:wintabs_buflist = l:tbuflist
            call wintabs#init()
        endif
        norm G
	endif
endfunction

function! s:NewTerm(cmd) abort
    " a:cmd may be an empty string
    let cmd = len(a:cmd) ? a:cmd : s:default_shell
    " new terminal
	let l:term_height = s:TermHeight(0.3)
	" terminal buffer numbers like [1, 56, 78]
	let l:tbuflist = filter(copy(nvim_list_bufs()), 'getbufvar(v:val, "&buftype") == "terminal"')
    " same command terminal buffers
	let l:buflist = filter(copy(l:tbuflist), 
        \'substitute(bufname(v:val), "\\", "/", "g") =~ substitute(cmd, "\\", "/", "g")."$"')
    if &buftype == 'terminal' || s:GoToTerm()
        " open a new terminal
        execute 'terminal' cmd 
    else
        " create a new terminal in split
        execute 'belowright' l:term_height.'split term://'.cmd 	
        " bring other terminal buffers into this window
        let w:wintabs_buflist = l:tbuflist
        call wintabs#init()
    endif
	" if the cmd has argumets, delete existing with the same cmd
	if len(split(cmd, ' \+')) > 1 && len(l:buflist) > 0
		execute 'bdelete!' join(l:buflist)
	endif
endfunction

function! Term(cmd)
    " a:cmd - string | number | float - the cmd name or the desired win height
    " if a:cmd is a number
    if index([v:t_number, v:t_float], type(a:cmd)) != -1
        call s:ToggleTerm(a:cmd)
    else
        call s:NewTerm(a:cmd)
    endif
endfunction

" delete all terminal buffers or the current one
function! DelTerms()
    if &buftype == 'terminal'
        " delete the current one
        if len(w:wintabs_buflist) > 1
            let other = filter(copy(w:wintabs_buflist), bufnr().' != v:val')[0]
            execute 'buffer' other
            bdelete! #
        else " just delete it
            bdelete!
        endif
    else
        let l:terms = filter(copy(nvim_list_bufs()), 'getbufvar(v:val, "&buftype") == "terminal"')
        if len(l:terms) > 0
            execute 'bdelete!' join(l:terms)
        endif
    endif
endfunction

