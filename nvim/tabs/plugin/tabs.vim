hi! Tabs_Status guifg=white guibg=#0A7ACA
hi! link Tabs_Status_NC StatusLine
" hi Tabs_Num guifg=yellow gui=bold
hi! link Tabs_Num StatusLine

function! StatusLine(bufnr)
    let hi_stat = a:bufnr == bufnr() ? '%#Tabs_Status#' : '%#Tabs_Status_NC#'
    let ft = getbufvar(a:bufnr, '&filetype')
    if exists('g:tabs_custom_stl') && index(g:tabs_custom_stl, ft) != -1  " custom buffer
        return hi_stat . ' %{&filetype} %* %= %l/%L '
    endif
    let text = hi_stat . ' %{toupper(mode())} %*'  " mode
    let text .= '%<%#StatusLineNC#' . TabsGetBufsText(a:bufnr)  " tabs
    let text .= hi_stat . '%= ' " custom highlighting and right align
    let bt = getbufvar(a:bufnr, '&buftype')
    if len(bt)
        let text .= toupper(bt)  " only buftype
    else
        let text .= '%{&filetype} %{WebDevIconsGetFileFormatSymbol()}'  " file type
        let text .= ' %l.%c/%L'  " line.col/lines
    endif
    let additional = exists('g:tabs_statusline_add') ? g:tabs_statusline_add : ''
    return text . ' ' . additional . ' %*'
endfunction

function! TabsGetBufsText(bufnr)
    let win = bufwinid(a:bufnr)
    let bufs = getwinvar(win, 'tabs_buflist')
    if !len(bufs)
        let bufs = [a:bufnr]
    endif
    let text = ''
    let i_buf = 1
    let is_current_win = win_getid() == win
    for buf in bufs
        let name = bufname(buf)
        let name = len(name) ? fnamemodify(name, ':t') : '[No name]'
        if buf == a:bufnr
            let text .= '%#TabLineSel# %{&filetype!=""?WebDevIconsGetFileTypeSymbol() . " ":""}' . name . '%m %*'
        else
            let num = is_current_win ? i_buf . ':' : ''
            let text .= ' ' . num . name . ' '
        endif
        let i_buf += 1
    endfor
    return text
endfunction

" ======================== Public Functions ============================

function! TabsReload()
    let buf = bufnr()
    if exists('w:tabs_buflist')
        if index(w:tabs_buflist, buf) == -1  " maybe added
            call add(w:tabs_buflist, buf)
        else  " maybe removed
            call filter(w:tabs_buflist, {_, buf -> buflisted(buf)})
        endif
    elseif bufname(buf) == '' && !getbufvar(buf, '&modified')  " empty
        let w:tabs_buflist = []
    else
        let w:tabs_buflist = [buf]
    endif
    " redrawstatus
endfunction

function! TabsAllBuffers() abort

    let w:tabs_buflist = []
    for buf in range(1, bufnr('$'))
        let empty = bufname(buf) == '' && !getbufvar(buf, '&modified')
        if bufexists(buf) && !empty
            call add(w:tabs_buflist, buf)
        endif
    endfor
    call TabsReload()
endfunction

function! TabsNext()
    if len(w:tabs_buflist) < 2  " too few tabs
        return
    endif
    let buf = bufnr(@%)
    let i_buf = index(w:tabs_buflist, buf)
    if i_buf == len(w:tabs_buflist) - 1
        let i_next = 0
    else
        let i_next = i_buf + 1
    endif
    call nvim_set_current_buf(w:tabs_buflist[i_next])
endfunction

function! TabsGo(...)
    let last = bufnr()
    if !a:0  " jump to alt
        if exists('w:tabs_buflist')
            if !exists('w:tabs_alt_file') || index(w:tabs_buflist, w:tabs_alt_file) == -1 || w:tabs_alt_file == last
                call TabsNext()
            else
                call nvim_set_current_buf(w:tabs_alt_file)
            endif
        else
            echo 'Unchartered waters!'
        endif
    elseif a:1 < 0  " a:to is a bufnr
        call nvim_set_current_buf(-a:1)
    else  " to is an index
        if a:1 < len(w:tabs_buflist)
            call nvim_set_current_buf(w:tabs_buflist[a:1])
        else
            echo 'No buffer at ' . a:1
        endif
    endif
    if last != bufnr()
        let w:tabs_alt_file = last
    else
        let w:tabs_alt_file = bufnr()
    endif
endfunction

function! TabsClose()
    if &buftype == 'terminal'
        let delcmd = 'bdelete!'
    elseif !&modifiable
        bdelete
        return
    else
        let delcmd = 'bdelete'
    endif
    call TabsGo()
    execute delcmd w:tabs_alt_file
    call TabsReload()
endfunction

augroup Tabs
    autocmd!
    autocmd FileType,TermOpen * execute 'setlocal statusline=%!StatusLine(' . bufnr() .')' | call TabsReload()
augroup END
