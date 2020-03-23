call sign_define('file', {'linehl': 'PmenuSel', 'text': ''})

let s:split_height = 10

function! s:FuzzyFile(chan, data, name)
    execute 'bot' s:split_height - 1 . 'sp +enew'
    setlocal nonumber norelativenumber nocursorline laststatus=0 buftype=nofile
    let b:file_list = a:name == 'stdout' ? a:data[:-2] : a:data
    call s:Reload(a:data)
    cnoremap <buffer> <tab> <cmd>call s:Action(1)<cr>
    cnoremap <buffer> <up> <cmd>call s:Neighbour(-1)<cr>
    cnoremap <buffer> <down> <cmd>call s:Neighbour(1)<cr>
    autocmd CmdlineChanged <buffer> call s:Reload(b:file_list)
    let cancelled = input({'prompt': '> ', 'cancelreturn': 1}) == 1  " cancelled
    set laststatus=2
    if cancelled
        bdelete
    else
        call s:Action(0)
    endif
endfunction

function! s:Action(menu)
    let signs = sign_getplaced(bufnr())[0]['signs']
    if empty(signs)
        return
    endif
    let file = trim(getline(signs[0]['lnum']))
    if a:menu
        let choice = confirm('', "rename")
        redraw
        if !choice
            return
        elseif choice == 1
            let destination = fnamemodify(getcwd() . '/' . input('dest: ', file), ':p')
            if destination != fnamemodify(file, ':p')
                execute 'silent! !move' file destination
            endif
        endif
    else
        bdelete
        for line in readfile(file, 'b', 10)
            if line =~ nr2char(10)  " binary
                execute 'silent! !start' file
                return
            endif
        endfor
        execute 'e' file
    endif
endfunction

function! s:Neighbour(direc) abort
    let signs = sign_getplaced(bufnr())[0]['signs']
    if empty(signs)
        return
    endif
    let lnum = signs[0]['lnum'] + a:direc
    if lnum > s:split_height || empty(getline(lnum))
        return
    endif
    call sign_unplace('', {'id': signs[0]['id']})
    call sign_place(0, '', 'file', bufnr(), {'lnum': lnum})
    redraw
endfunction

function! s:Reload(lines) abort
    let pattern = substitute(getcmdline(), ' ', '.*', 'g')
    let lines = filter(copy(a:lines), {_, f -> f =~ pattern})
    let signs = sign_getplaced(bufnr())[0]['signs']
    if empty(lines)
        if !empty(signs)
            call sign_unplace('', {'id': signs[0]['id']})
        endif
    elseif empty(signs)
        call sign_place(0, '', 'file', bufnr(), {'lnum': s:split_height})
    else
        call s:Neighbour(s:split_height - signs[0]['lnum'])
    endif
    if len(lines) < s:split_height
        let empty_lines = repeat([''], s:split_height - len(lines))
        let lines = empty_lines + lines
    else
        let lines = lines[len(lines) - s:split_height - 1:]
    endif
    call map(lines, {i, line -> setline(i + 1, line)})
    redraw
endfunction

function! Fuzzy(cmd) abort
    echo 'Searching...'
    if type(a:cmd) == v:t_string
        call jobstart(a:cmd, {
            \ 'on_stdout': funcref('s:FuzzyFile'),
            \ 'stdout_buffered': 1})
    else
        call s:FuzzyFile(0, a:cmd, 'direct')
    endif
endfunction

