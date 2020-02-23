" config vars:
" g:tabs_statusline_add - additional things to add to statusline
" g:tabs_custom_stl - list of filetypes to show in place of mode

function! StatusLine(bufnr)
    " this is what is set in the autocmds
    let tabs_section = '%<%#StatusLineNC#' . TabsGetBufsText(a:bufnr)  " tabs
    if a:bufnr == bufnr()
        let current = 1
        let hi_stat = '%#Tabs_Status#'
        let start = hi_stat . ' %{toupper(mode())} '  " mode
    else
        let current = 0
        let hi_stat = '%#Tabs_Status_NC#'
        let start = hi_stat . ' %{win_getid() == g:tabs_alt_win ? "#" : winnr()} '
    endif
    let ft = getbufvar(a:bufnr, '&filetype')
    if exists('g:tabs_custom_stl') && has_key(g:tabs_custom_stl, ft)  " custom buffer
        let custom = substitute(g:tabs_custom_stl[ft], ':tabs\>', tabs_section, '')
        return start . '%{&filetype} %#StatusLineNC# ' . custom " filetype and custom
    endif
    let bt = getbufvar(a:bufnr, '&buftype')
    if len(bt) && bt != 'terminal'
        let begin = current ? hi_stat : start
        return begin . ' ' . toupper(bt) . ' ' . tabs_section . hi_stat  " buftype and tabs
    endif
    let text = start . tabs_section  " win and tabs
    let text .= hi_stat . '%= ' " custom highlighting and right align
    if bt == 'terminal'
        return text . toupper(bt) . ' '
    endif
    return text . get(g:, 'tabs_statusline_add', '')  " with additional from user
endfunction

function! TabsGetBufsText(bufnr)
    " get the section of the tabs
    let win = bufwinid(a:bufnr)
    let bufs = getwinvar(win, 'tabs_buflist', [a:bufnr])
    let text = ''
    let i_buf = 1
    let is_current_win = win_getid() == win
    let i_this = index(bufs, a:bufnr)
    let alt = s:TabsGetAlt(win)  " alternate buffer for the current win
    for buf in bufs
        let name = bufname(buf)
        let name = len(name) ? fnamemodify(name, ':t') : '[No name]'
        if buf == a:bufnr
            let ft = getbufvar(buf, '&filetype')
            if empty(ft)
                let icon = '%#TabLineSel# '
            else
                let hl_icon = 'TabsFt_' . ft " highlighting for the icons
                let hl_icon = '%#' . (hlID(hl_icon) ? hl_icon : 'TabLineSel') . '#'
                let icon = hl_icon . ' %{WebDevIconsGetFileTypeSymbol()} '
            endif
            let text .= icon . '%#TabLineSel#' . name . '%m %*'
        else
            let num = is_current_win ? (buf == alt ? '#' : i_buf) . ':' : ''
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
        call filter(w:tabs_buflist, {_, buf -> buflisted(buf)})  " maybe removed
        if index(w:tabs_buflist, buf) == -1  " maybe added
            call add(w:tabs_buflist, buf)
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
    " cycle through tabs
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

function! s:TabsGetAlt(win)  " get the alternate buffer for the given window
    let bufs = getwinvar(a:win, 'tabs_buflist', [])
    let l_bufs = len(bufs)
    if l_bufs < 2
        return
    endif
    let alt = getwinvar(a:win, 'tabs_alt_file', 0)
    let i_alt = index(bufs, alt)
    let current = winbufnr(a:win)
    if i_alt == -1 || alt == current
        let i_current = index(bufs, current)
        if i_current == l_bufs - 1 " last, return first
            return bufs[0]
        endif
        return bufs[i_current + 1]  " next
    endif
    return alt
endfunction

function! TabsGo(where)
    " go to the specified buffer or win
    if type(a:where) == v:t_float  " win
        let where = float2nr(a:where)
        if !where  " jump to alt
            let alt_win = win_getid(get(g:, 'tabs_alt_win', 0))
            if alt_win
                call win_gotoid(alt_win)
            else
                let wins = filter(nvim_list_wins(), {_, val -> val != win_getid()})
                if len(wins)
                    call win_gotoid(wins[0])
                endif
            endif
        else  " a:where is a win (shown on the bar)
            call win_gotoid(win_getid(where))
        endif
    else  " buffer
        " jump through the tabs
        let last = bufnr()
        if !a:where  " alt
            let alt = s:TabsGetAlt(winnr())
            if alt
                call nvim_set_current_buf(alt)
            endif
        else  " to is an index + 1 (shown on the bar)
            if a:where <= len(w:tabs_buflist)
                call nvim_set_current_buf(w:tabs_buflist[a:where - 1])
            else
                echo 'No buffer at ' . (a:where)
            endif
        endif
        if last != bufnr()
            let w:tabs_alt_file = last
        else
            let w:tabs_alt_file = bufnr()
        endif
    endif
endfunction

function! TabsClose()
    " close current tab
    let bang = &buftype == 'terminal' ? '!' : ''
    let to_go = exists('w:tabs_alt_file') ? index(w:tabs_buflist, w:tabs_alt_file) : -1
    if to_go == -1  " alt file closed
        let to_go = index(w:tabs_buflist, bufnr()) - 1
        if to_go < 0
            if len(w:tabs_buflist) < 2  " last buffer, just close
                execute 'bdelete' . bang
                return
            endif
            let to_go += 2  " to the right
        endif
    endif
    call TabsGo(to_go)  " to the alt file
    execute 'bdelete'.bang w:tabs_alt_file
    call TabsReload()
endfunction

" add the filetype and fileformat to the <c-g>
noremap <c-g> <cmd>file <bar> echon '  ft:'.&filetype '  eol:'.&fileformat<cr>

" highlightings used

hi Tabs_Status guifg=white guibg=#0A7ACA
hi link Tabs_Status_NC StatusLine
hi Tabs_Error guifg=black guibg=red
hi Tabs_Warning guifg=black guibg=yellow

let ft_hl = [
    \ ['vim', 'green'],
    \ ['jade', 'green'],
    \ ['ini', 'yellow'],
    \ ['md', 'blue'],
    \ ['yml', 'yellow'],
    \ ['config', 'yellow'],
    \ ['conf', 'yellow'],
    \ ['json', 'yellow'],
    \ ['html', 'orange'],
    \ ['styl', 'cyan'],
    \ ['css', 'cyan'],
    \ ['coffee', 'Red'],
    \ ['js', '#F7DF1E'],
    \ ['javascript', '#F7DF1E'],
    \ ['javascriptreact', '#00D8FF'],
    \ ['php', 'Magenta'],
    \ ['python', '#4584B6'],
    \ ['ds_store', 'Gray'],
    \ ['gitconfig', 'Gray'],
    \ ['gitignore', 'Gray'],
    \ ['bashrc', 'Gray'],
    \ ['bashprofile', 'Gray',]]

for hl in ft_hl
    let bg = synIDattr(hlID('Normal'), 'bg')
    execute 'hi TabsFt_' . hl[0] 'guifg=' . hl[1] 'guibg=' . bg
endfor

function! s:OnNew() abort
    if get(b:, 'tabs_status_set', 0)
        " already set
        return
    endif
    let b:tabs_status_set = 0
    execute 'setlocal statusline=%!StatusLine(' . bufnr() .')'
    call TabsReload()
    let alt = bufnr('#')
    if index(w:tabs_buflist, alt) != -1  " for when closing just after opening
        let w:tabs_alt_file = alt
    endif
endfunction

augroup Tabs
    autocmd!
    autocmd BufRead,BufNewFile,FileType,TermOpen * call s:OnNew()
    " save the current window number before jumping to jump back
    autocmd WinLeave * let g:tabs_alt_win = win_getid()
augroup END
