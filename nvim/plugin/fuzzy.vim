call sign_define('file', {'linehl': 'PmenuSel', 'text': '>'})

let s:split_height = 10
" let s:cache = {}
" let s:cache_key = ''

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
    " if a:name == 'stdout'
    "     let s:cache[s:cache_key]['result'] = a:data
    " endif
endfunction

function! Action(menu)
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
    if len(lines) < s:split_height
        let empty_lines = repeat([''], s:split_height - len(lines))
        let lines = empty_lines + lines
    else
        let lines = lines[len(lines) - s:split_height - 1:]
    endif
    call map(lines, {i, line -> setline(i + 1, line)})
    redraw
endfunction

function! Fuzzy(cmd, dir) abort
    echo 'Searching...'
    if type(a:cmd) == v:t_string
        let dir = empty(a:dir) ? '.' : a:dir
        " let s:cache_key = a:cmd . '::' . a:dir
        " let dirtime = getftime(dir)
        " if get(s:cache, s:cache_key, {'time': 0})['time'] == dirtime
        "     call FuzzyFile(0, s:cache[s:cache_key]['result'], 'cache')
        " else
        "     let s:cache[s:cache_key] = {'time': dirtime, 'result': []}
            call jobstart(a:cmd, {
                \ 'on_stdout': funcref('FuzzyFile'),
                \ 'stdout_buffered': 1,
                \ 'cwd': dir})
            " call FuzzyFile(0, systemlist(a:cmd . ' '. a:dir), 'system')
        " endif
    else
        call FuzzyFile(0, a:cmd, 'direct')
    endif
endfunction

" --sort modified (slow)
noremap - <cmd>call Fuzzy('rg --files', repeat('../', v:count))<cr>
