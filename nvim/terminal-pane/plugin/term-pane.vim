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

" get terminal buffers or windows
function! s:Terminals(...) abort
    if a:0  " windows
        let list = nvim_list_wins()
        let Item = function('winbufnr')
    else  " buffers
        let list = nvim_list_bufs()
        let Item = {val -> val}
    endif
    return filter(list, {_, val -> getbufvar(Item(val), '&buftype') == 'terminal'})
endfunction

" find and go to terminal pane, return success
function! s:GoToTerm() abort
	" terminal windows
	let l:tbufwins = s:Terminals(1)
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
		return 1
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
        return 1
    elseif s:GoToTerm()
        return 1
    endif
    " terminal buffers
    let l:tbuflist = s:Terminals()
    " if last opened terminal is hidden but exists
    if exists('g:term_current_buf') && buflisted(g:term_current_buf)
        execute 'belowright' l:term_height.'split +buffer\' g:term_current_buf
    elseif len(l:tbuflist) " choose one of the others
        execute 'belowright' l:term_height.'split +buffer\' l:tbuflist[0]
    else " create a new one
        return 0
    endif
    " bring other terminal buffers into this window
    let w:wintabs_buflist = l:tbuflist
    call wintabs#init()
    return 1
endfunction

function! Term(cmd, ...)
    " a:cmd - string | number | float - the cmd name or the desired win height
    " if a:cmd is a number
    if index([v:t_number, v:t_float], type(a:cmd)) != -1
        if s:ToggleTerm(a:cmd)
            return
        endif
        let cmd = s:default_shell
    else
        let cmd = len(a:cmd) ? a:cmd : s:default_shell
    endif
    " new terminal
	let l:term_height = s:TermHeight(0.3)
	" terminal buffer numbers like [1, 56, 78]
	let l:tbuflist = s:Terminals()
    " same command terminal buffers
    let dir = a:0 > 0 ? a:1 : '.'
    let buf_name = 'term://'.dir.'//'.cmd
    if &buftype == 'terminal' || s:GoToTerm()
        " open a new terminal
        execute 'edit' buf_name
    else
        " create a new terminal in split
        execute 'belowright' l:term_height.'split '.buf_name
        " bring other terminal buffers into this window
        let w:wintabs_buflist = l:tbuflist
        call wintabs#init()
    endif
    tnoremap <buffer> <cr> <cmd>call timer_start(500, 'RenameTerm')<cr><cr>
    tnoremap <buffer> <c-c> <cmd>call timer_start(500, 'RenameTerm')<cr><c-c>
	" if the cmd has argumets, delete existing with the same cmd
    for buf in l:tbuflist
        let name = substitute(bufname(buf), '//\d\+:', '//', '')
        echo name buf_name
        if name == buf_name
            execute 'bdelete!' buf
        endif
    endfor
endfunction

" delete all terminal buffers or the current one
function! DelTerms()
    if &buftype == 'terminal'
        " delete the current one
        if len(w:wintabs_buflist) > 1
            let other = filter(copy(w:wintabs_buflist), bufnr().' != v:val')[0]
            execute 'buffer' other
            bwipeout! #
        else " just delete it
            bwipeout!
        endif
    else
        let l:terms = s:Terminals()
        if len(l:terms) > 0
            execute 'bwipeout!' join(l:terms)
        endif
    endif
endfunction

" use the current process in the terminal as the buffer name
function! RenameTerm(timer)
    let current_name = bufname()
    let cmd_part = substitute(current_name, 'term:\/\/.*\/\/\d\+:', '', '')
    if cmd_part =~ ' ' || &buftype != 'terminal' " dont rename one with a space or a normal file
        return
    endif
    let pid = jobpid(&channel)
    let child = pid
    while child
        let ch = nvim_get_proc_children(child)
        if len(ch) == 1
            let child = ch[0]
        else
            break
        endif
    endwhile
    let name = substitute(nvim_get_proc(child)['name'], '.exe', '', '')
    if name == cmd_part " to prevent unnecessary unlisted buffer creation
        return
    endif
    let begin = 'term://'
    let dirstart = len(begin)
    let dir_part = current_name[dirstart: stridx(current_name, '//', dirstart) - 1]
    let new_name = begin.dir_part.'//'.child.':'.name
    execute 'file '.new_name
    " execute 'bwipeout!' bufnr(@#)
endfunction
