call sign_define('file', {'linehl': 'PmenuSel', 'text': '>'})


function! FuzzyFile(chan, data, name)
    bel 10sp +enew
    let b:file_list = a:data
    setlocal nonumber norelativenumber buftype=nofile
    autocmd TextChangedI <buffer> call Reload(Filter())
    inoremap <buffer> <esc> <esc><cmd>bd!<cr>
    inoremap <buffer> <cr> <cmd>call Open()<cr>
    let b:sign = sign_place(0, '', 'file', bufnr(), {'lnum': 9})
    call Reload(a:data)
    call feedkeys('Go')
endfunction

function! Open()
    let file = trim(getline(9))
    call feedkeys("\<esc>")
    bd!
    if !empty(file)
        execute 'e' file
    endif
endfunction

function! Filter() abort
    if line('.') == 9
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
    if len(a:lines) < 9
        let empty_lines = repeat([''], 9 - len(a:lines))
        let lines = empty_lines + a:lines
    else
        let lines = a:lines
    endif
    let lnum = 1
    for line in lines[:8]
        call setline(lnum, line)
        let lnum += 1
    endfor
    if empty(a:lines)
        call sign_unplace('', {'id': b:sign})
    elseif empty(sign_getplaced(bufnr())[0]['signs'])
        call sign_place(0, '', 'file', bufnr(), {'lnum': 9})
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

noremap - <cmd>call Fuzzy('rg --files ' . repeat('../', v:count))<cr>
