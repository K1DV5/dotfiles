onoremap ii <cmd>call <sid>in_indent(1)<cr>
vnoremap ii <cmd>call <sid>in_indent(1)<cr>
onoremap ai <cmd>call <sid>in_indent(0)<cr>
vnoremap ai <cmd>call <sid>in_indent(0)<cr>

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

function! s:get_offsets(line, ind)
    let up = 1
    while a:line - up && (indent(a:line - up) >= a:ind || empty(trim(getline(a:line - up))))
        let up += 1
    endwhile
    let down = 1
    let last = line('$')
    while a:line + down <= last && (indent(a:line + down) >= a:ind || empty(trim(getline(a:line + down))))
        let down += 1
    endwhile
    return [up, down]
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
    let [up, down] = s:get_offsets(line, ind)
    call cursor(line - up + a:around, 1)
    if mode() == 'n'
        norm V
        call cursor(line + down - 1, 1)
        return
    elseif mode() == 'v'
        call feedkeys('Vo')
    elseif mode() == 'V'
        call feedkeys('o')
    endif
    if down > 1
        call feedkeys((down - 1) . 'j')
    endif
endfunction




