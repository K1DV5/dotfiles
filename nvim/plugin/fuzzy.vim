let s:split_height = 10

function! s:FuzzyFile(chan, data, name)
    execute 'bot' s:split_height - 1 . 'sp +enew'
    setlocal nonumber norelativenumber laststatus=0 buftype=nofile
    let b:file_list = a:name == 'stdout' ? a:data[:-2] : a:data
    call s:Reload(b:file_list)
    cnoremap <buffer> <tab> <cmd>call s:Action(1)<cr>
    cnoremap <buffer> <up> <cmd>call s:Neighbour(-1)<cr>
    cnoremap <buffer> <down> <cmd>call s:Neighbour(1)<cr>
    autocmd CmdlineChanged <buffer> call s:Reload(b:file_list)
    let cancelled = input({'prompt': '> ', 'cancelreturn': 1}) == 1
    set laststatus=2
    if cancelled
        bdelete
    else
        call s:Action(0)
    endif
endfunction

function! s:Action(menu)
    let file = getline('.')
    if empty(file)
        return
    elseif a:menu
        let action = confirm(file, "rename\ndelete")
        redraw
        if !action
            return
        elseif action == 1
            let destination = input('dest: ', file)
            call rename(file, destination)
            call map(b:file_list, {_, f -> f == file ? destination : f})
        elseif action == 2
            call delete(file)
            call filter(b:file_list, {_, f -> f != file})
        endif
        call s:Reload(b:file_list)
    else
        bdelete
        for line in readfile(file, 'b', 20)
            if line =~ nr2char(10)  " binary
                call jobstart('start '. file)
                return
            endif
        endfor
        execute 'e' file
    endif
endfunction

function! s:Neighbour(direc) abort
    let lnum = line('.') + a:direc
    if empty(getline(lnum))
        return
    endif
    call cursor(lnum, 1)
    redraw
endfunction

function! s:Reload(lines) abort
    let pattern = substitute(getcmdline(), ' ', '.\\{-}', 'g')
    let lines = filter(copy(a:lines), {_, f -> f =~ pattern})
    let l_lines = len(lines)
    if !l_lines
        set winhighlight=CursorLine:Normal
    elseif !&winhighlight
        set winhighlight=CursorLine:PmenuSel
    endif
    if l_lines < s:split_height
        let empty_lines = repeat([''], s:split_height - l_lines)
        let lines = empty_lines + lines
        let l_lines = s:split_height
    endif
    call map(lines, {i, line -> setline(i + 1, line)})
    let last = line('$')
    if last > l_lines
        call deletebufline(bufnr(), l_lines + 1, last)
    endif
    call cursor(l_lines, 1)
    norm zb
    redraw
endfunction

function! Fuzzy(cmd) abort
    echo 'Searching...'
    if type(a:cmd) == v:t_string
        call jobstart(a:cmd, {'on_stdout': funcref('s:FuzzyFile'), 'stdout_buffered': 1})
    else
        call s:FuzzyFile(0, a:cmd, 'direct')
    endif
endfunction
