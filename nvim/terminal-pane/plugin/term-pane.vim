" term plugin
" Written by K1DV5
" https://github.com/K1DV5/term.nvim
"
" Constant(s):
let s:default_shell = exists('term_default_shell')? g:term_default_shell : &shell


" define command
command! -nargs=1 T call Term("<args>", 0)
" open big terminal window
noremap <leader>T <cmd>call SwitchTerm(&lines - &winheight - 4)<cr>
" open file in normal window
noremap gf <cmd>call ViewFile(expand('<cfile>'))<cr>

function! ViewFile(file) abort
	execute 'resize' l:term_height
	wincmd k
	execute 'view' fnameescape(a:file)
endfunction

function! TermHeight(size) abort
	if a:size > 1
		let l:term_height = a:size
	else
		if bufname(@%) =~ '^term://'
			let l:alt_window_id = nvim_list_wins()[index(nvim_list_wins(), bufwinid(@%)) - 1]
			let l:term_height = float2nr((winheight(l:alt_window_id) + winheight(0) + 1) * a:size)
		else
			let l:term_height = float2nr(winheight(0) * a:size) 
		endif
	endif	
	return l:term_height
endfunction

function! SwitchTerm(size) abort
    " if a terminal window is open
        " if it is less than the argument:size high, maximize to the max
        " else hide the terminal window
    " else bring the hidden terminal window, making it the argument:size high
	let l:term_height = TermHeight(a:size)
	" work only if buffer is a normal file
	if !buflisted(@%)
		return
	endif
	" if the size is less than 1, it will be taken as the fraction of the file
	" window
	if a:size > 1
		let l:term_height = a:size
	else
		if bufname(@%) =~ '^term://'
			let l:alt_window_id = nvim_list_wins()[index(nvim_list_wins(), bufwinid(@%)) - 1]
			let l:term_height = float2nr((winheight(l:alt_window_id) + winheight(0) + 1) * a:size)
		else
			let l:term_height = float2nr(winheight(0) * a:size) 
		endif
	endif	
	" if in terminal pane
	if bufname('%') =~ '^term://'
		" if different height from the wanted
		if winheight(0) < l:term_height
			execute 'resize' l:term_height
		else
			let g:term_current_buf = bufnr('%')
			hide
		endif
	else
		" if last opened terminal is hidden
		if exists('g:term_current_buf') && buflisted(g:term_current_buf)
			let l:binary = split(bufname(g:term_current_buf), ':')[-1]
			call Term(l:binary, 1)
		else
			call Term(s:default_shell, 1)
		endif
		" if we end up in terminal pane and its a different height than wanted
		if bufname('%') =~ '^term://' && winheight(0) < l:term_height
			execute 'resize' l:term_height
		endif
	endif
endfunction

function! Term(binary, ...)
	let l:term_height = TermHeight(0.3)
	" terminal buffer numbers like [1, 56, 78]
	let l:tbuflist = filter(copy(nvim_list_bufs()),
		\'bufname(v:val) =~ "^term://" && buflisted(v:val)')
	" terminal buffer numbers that contain the name
	let l:buflist = filter(copy(l:tbuflist), 
		\'substitute(bufname(v:val), "\\", "/", "g")
		\=~ substitute(a:binary, "\\", "/", "g")."$"')
	" if no additional args are not given, delete existing with the same name
	if a:0 == 0 && len(l:buflist) > 0
		execute 'bdelete!' join(l:buflist)
	endif
	" terminal window buffer ids
	let l:tbufwins = filter(copy(nvim_list_wins()), 'bufname(winbufnr(v:val)) =~ "^term://"')
	" if no optional args are given
	if a:0 == 0
		" if there is a terminal window
		if l:tbufwins != []
			" go to that window
			call win_gotoid(l:tbufwins[0])
			" open a new terminal
			execute 'terminal' a:binary 
		else
			" create a new terminal in split
			execute 'belowright' l:term_height.'sp term://'.a:binary 	
			" bring other terminal buffers into this window
			let w:wintabs_buflist = l:tbuflist
			call wintabs#init()
		endif
	else
		if l:tbufwins != []
			" if not in the terminal window already
			if index(l:tbufwins, nvim_get_current_win()) == -1
				" go there
				call win_gotoid(l:tbufwins[0])
			else
				" remember this window as the current terminal
				let g:term_current_buf = bufnr('%')
				if a:1 == 0
					execute 'terminal' a:binary
				else
					hide
				endif
			endif
		elseif l:tbufwins == [] && l:buflist != []
			execute 'belowright sb +resize\' l:term_height 'term://*'.a:binary
			let w:wintabs_buflist = l:tbuflist
			call wintabs#init()
		elseif a:1 == 0
			execute 'belowright' l:term_height.'sp term://'.a:binary
			let w:wintabs_buflist = l:tbuflist
			call wintabs#init()
		elseif l:tbuflist != []
			execute 'belowright sb +resize\' l:term_height tbuflist[0]
			let w:wintabs_buflist = l:tbuflist
			call wintabs#init()
		else
			execute 'belowright' l:term_height.'sp term://'.a:binary
		endif
	endif
endfunction
