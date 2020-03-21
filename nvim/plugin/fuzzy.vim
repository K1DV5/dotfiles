call sign_define('file', {'linehl': 'PmenuSel', 'text': '>'})

let s:split_height = 10

function! FuzzyFile(chan, data, name)
    execute 'bel' s:split_height . 'sp +enew'
    let b:file_list = a:name == 'stdout' ? a:data[:-2] : a:data
    setlocal nonumber norelativenumber buftype=nofile
    autocmd TextChangedI <buffer> call Reload(Filter())
    inoremap <buffer> <esc> <esc><cmd>bd!<cr>
    inoremap <buffer> <cr> <cmd>call Open()<cr>
    inoremap <buffer> <up> <cmd>call Neighbour(-1)<cr>
    inoremap <buffer> <down> <cmd>call Neighbour(1)<cr>
    call Reload(a:data)
    call feedkeys('Go')
endfunction

function! Open()
    let signs = sign_getplaced(bufnr())[0]['signs']
    if empty(signs)
        return
    endif
    let file = trim(getline(signs[0]['lnum']))
    call feedkeys("\<esc>")
    bd!
    if !empty(file)
        execute 'e' file
    endif
endfunction

function! Neighbour(direc) abort
    let signs = sign_getplaced(bufnr())[0]['signs']
    if empty(signs)
        return
    endif
    let lnum = signs[0]['lnum'] + a:direc
    if lnum == s:split_height || empty(getline(lnum))
        return
    endif
    call sign_unplace('', {'id': signs[0]['id']})
    call sign_place(0, '', 'file', bufnr(), {'lnum': lnum})
endfunction

function! Filter() abort
    if line('.') == s:split_height - 1
        call feedkeys("\<cr>", 'n')
        return b:file_list
    endif
    let line = getline('.')
    if empty(trim(line))
        return b:file_list
    endif
    let pattern = substitute(line, ' ', '.*', 'g')
    return filter(copy(b:file_list), {_, f -> f =~ pattern})
endfunction

function! Reload(lines) abort
    if len(a:lines) < s:split_height - 1
        let empty_lines = repeat([''], s:split_height - 1 - len(a:lines))
        let lines = empty_lines + a:lines
    else
        let lines = a:lines[len(a:lines) - s:split_height + 1:]
    endif
    let lnum = 1
    for line in lines
        call setline(lnum, line)
        let lnum += 1
    endfor
    let signs = sign_getplaced(bufnr())[0]['signs']
    if empty(a:lines)
        call sign_unplace('', {'id': signs[0]['id']})
    elseif empty(signs)
        call sign_place(0, '', 'file', bufnr(), {'lnum': s:split_height - 1})
    else
        call Neighbour(s:split_height - 1 - signs[0]['lnum'])
    endif
endfunction

function! Fuzzy(cmd) abort
    if type(a:cmd) == v:t_string
        call jobstart(a:cmd, {
            \ 'on_stdout': funcref('FuzzyFile'),
            \ 'stdout_buffered': 1})
    else
        call FuzzyFile(0, a:cmd, 'direct')
    endif
endfunction

noremap - <cmd>call Fuzzy('rg --files --sort modified ' . repeat('../', v:count))<cr>
