call sign_define('file', {'linehl': 'PmenuSel', 'text': '>'})

let s:split_height = 10

function! FuzzyFile(chan, data, name)
    execute 'bel' s:split_height . 'sp +enew'
    let b:file_list = a:name == 'stdout' ? a:data[:-2] : a:data
    call Reload(a:data)
    setlocal nonumber norelativenumber nocursorline buftype=nofile filetype=txt
    cnoremap <buffer> <tab> <cmd>call Action(1)<cr>
    cnoremap <buffer> <up> <cmd>call Neighbour(-1)<cr>
    cnoremap <buffer> <down> <cmd>call Neighbour(1)<cr>
    autocmd CmdlineChanged <buffer> call Reload(b:file_list)
    redraw
    if input({'prompt': '> ', 'cancelreturn': 1}) == 1  " cancelled
        bdelete
    else
        call Action(0)
    endif
endfunction

function! Action(menu)
    let signs = sign_getplaced(bufnr())[0]['signs']
    if empty(signs)
        return
    endif
    let file = trim(getline(signs[0]['lnum']))
    bdelete
    if a:menu
        let choice = confirm('', "rename\nsystem open")
        if !choice
            return
        else
            echo choice
        endif
    else
        execute 'e' file
    endif
endfunction

function! Neighbour(direc) abort
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

function! Reload(lines) abort
    let pattern = substitute(getcmdline(), ' ', '.*', 'g')
    let lines = filter(copy(a:lines), {_, f -> f =~ pattern})
    if len(lines) < s:split_height
        let empty_lines = repeat([''], s:split_height - len(lines))
        let lines = empty_lines + lines
    else
        let lines = lines[len(lines) - s:split_height - 1:]
    endif
    let lnum = 1
    for line in lines
        call setline(lnum, line)
        let lnum += 1
    endfor
    let signs = sign_getplaced(bufnr())[0]['signs']
    if empty(lines)
        if !empty(signs)
            call sign_unplace('', {'id': signs[0]['id']})
        endif
    elseif empty(signs)
        call sign_place(0, '', 'file', bufnr(), {'lnum': s:split_height})
    else
        call Neighbour(s:split_height - signs[0]['lnum'])
    endif
    redraw
endfunction

function! Fuzzy(cmd) abort
    echo 'Searching...'
    if type(a:cmd) == v:t_string
        call jobstart(a:cmd, {
            \ 'on_stdout': funcref('FuzzyFile'),
            \ 'stdout_buffered': 1})
    else
        call FuzzyFile(0, a:cmd, 'direct')
    endif
endfunction

" --sort modified (slow)
noremap - <cmd>call Fuzzy('rg --files ' . repeat('../', v:count))<cr>
