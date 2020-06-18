let s:split_height = 10

function! s:fuzzy_file(chan, data, name)
    execute 'bot' s:split_height - 1 . 'sp +enew'
    setlocal nonumber norelativenumber laststatus=0 buftype=nofile
    let b:file_list = a:name == 'stdout' ? a:data[:-2] : a:data
    call s:reload(b:file_list)
    cnoremap <buffer> <tab> <cmd>call s:sink(getline('.'), 0)<cr>
    cnoremap <buffer> <up> <cmd>call s:neighbour(-1)<cr>
    cnoremap <buffer> <down> <cmd>call s:neighbour(1)<cr>
    autocmd CmdlineChanged <buffer> call s:reload(b:file_list)
    let cancelled = input({'prompt': '> ', 'cancelreturn': 1}) == 1
    set laststatus=2
    let selected = getline('.')
    bdelete
    if !empty(selected) && !cancelled
        call s:sink(selected, 1)
    endif
endfunction

function! s:action(selected, default)
    if a:default
        for line in readfile(a:selected, 'b', 20)
            if line =~ nr2char(10)  " binary
                call jobstart('start '. a:selected)
                return
            endif
        endfor
        execute 'e' a:selected
        return
    endif
    let action = confirm(a:selected, "rename\ndelete")
    redraw
    if !action
        return
    elseif action == 1
        let destination = input('destination: ', a:selected, 'file')
        call rename(a:selected, destination)
        call map(b:file_list, {_, f -> f == a:selected ? destination : f})
    elseif action == 2
        call delete(a:selected)
        call filter(b:file_list, {_, f -> f != a:selected})
    endif
    call s:reload(b:file_list)
endfunction

function! s:neighbour(direc) abort
    let lnum = line('.') + a:direc
    if empty(getline(lnum))
        return
    endif
    call cursor(lnum, 1)
    redraw
endfunction

function! s:reload(lines) abort
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

function! Fuzzy(cmd, ...) abort
    echo 'Searching...'
    let s:sink = a:0 ? a:1 : funcref('s:action')
    if type(a:cmd) == v:t_string
        call jobstart(a:cmd, {'on_stdout': funcref('s:fuzzy_file'), 'stdout_buffered': 1})
        " call s:fuzzy_file(0, systemlist(a:cmd), 'direct')
    else
        call s:fuzzy_file(0, a:cmd, 'direct')
    endif
endfunction
