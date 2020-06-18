onoremap ii <cmd>call <sid>in_indent(0)<cr>
vnoremap ii <cmd>call <sid>in_indent(0)<cr>
onoremap ai <cmd>call <sid>in_indent(1)<cr>
vnoremap ai <cmd>call <sid>in_indent(1)<cr>

let s:around = ['tex', 'vim', 'lua']

function! s:get_indent(line, direc)
    let lnum = a:line + a:direc
    while lnum < line('$') && !indent(lnum)
        if !empty(trim(getline(lnum)))
            break
        endif
        let lnum += a:direc
    endwhile
    return indent(lnum)
endfunction

function! s:get_offsets(line, ind, around)
    let up = 1
    while a:line - up && (indent(a:line - up) >= a:ind || empty(trim(getline(a:line - up))))
        let up += 1
    endwhile
    let down = 1
    let last = line('$')
    while a:line + down <= last && (indent(a:line + down) >= a:ind || empty(trim(getline(a:line + down))))
        let down += 1
    endwhile
    if a:around && (trim(getline(a:line + down)) == '}' || index(s:around, &filetype) > -1)
        let down += 1
        while a:line + down <= last && empty(trim(getline(a:line + down)))
            let down += 1
        endwhile
    endif
    return [up - !a:around, down]
endfunction

function! s:in_indent(around)
    let line = line('.')
    let ind = indent(line)
    if empty(trim(getline('.')))
        let ind = s:get_indent(line, 1)
        if !ind
            let ind = s:get_indent(line, -1)
        endif
    endif
    let [up, down] = s:get_offsets(line, ind, a:around)
    call cursor(line - up, 1)
    let mod = mode()
    if mod == 'n'
        norm V
        call cursor(line + down - 1, 1)
        return
    elseif mod == 'v'
        call feedkeys('Vo')
    elseif mod == 'V'
        call feedkeys('o')
    endif
    if down > 1
        call feedkeys((down - 1) . 'j')
    endif
endfunction




