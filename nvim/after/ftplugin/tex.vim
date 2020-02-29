" show max recommended columns
setlocal colorcolumn=80
" check spelling
set spell

" change normal equation to latex
inoremap <buffer> <c-space> <cmd>call Latexify(0)<cr>
" automate itemize and enumerate
noremap <buffer> <leader>xl <cmd>call ItemizeEnum()<cr>
" paste image to latex properly
noremap <buffer> <leader>ip <cmd>call InsertClipFigTex()<cr>
" remove unused pasted images in latex
noremap <buffer> <leader>ir <cmd>call PurgeUnusedImagesTex()<cr>

    function! Latexify(display) abort "{{{
        " convert to latex, requires pip install docal
python << EOF
import vim
from docal import eqn
from docal.handlers.latex import syntax
synt = syntax()
cline = vim.eval("getline('.')")
disp = False if int(vim.eval('a:display')) == 0 else True
txt, eq_asc = cline.rsplit('  ', 1) if '  ' in cline else ['', cline]
eq = eqn(eq_asc, disp=disp, syntax=synt).split('\n')
# "because they will be appended at the same line
eq.reverse()
vim.command(f"call setline('.', '{txt} {eq[-1]}')")
for e in eq[:-1]:
    vim.command(f"call append('.', '{e}')")
EOF
    endfunction

    " }}}
    function! ItemizeEnum() abort "{{{
        " automate itemize and enumerate in latex
        norm "xdipk
        let items = reverse(split(expand(@x), "\n"))
        let type = trim(items[-1]) == '.' ? 'enumerate' : 'itemize'
        if type == 'enumerate'
            let items = items[:-2]
        endif
        call append('.', '\end{'.type.'}')
        for i in items
            call append('.', '    \item '.i)
        endfor
        call append('.', '\setlength\itemsep{0pt}')
        call append('.', '\begin{'.type.'}')
        norm }
    endfunction

    " }}}
    function! InsertClipFigTex() abort "{{{
        " automate the saving to file and writing figure environments for
        " clipboard images to latex
        if &filetype == 'tex'
            let relpath = 'res'
            let imgpath = expand('%:h').'/'.relpath
            let ext = '.png'
            let fig_line = line('.')
            let line_split = split(getline(fig_line), '|', 1)
            let caption = trim(line_split[0])
            let label = len(line_split) > 1 ? trim(line_split[1]) : ''
            if exists('b:init_last_fig_pasted') && fig_line == b:init_last_fig_pasted[1] && filereadable(imgpath.'/'.b:init_last_fig_pasted[0].'.png')
                let imgname = b:init_last_fig_pasted[0]
                let img_write_success = 1
            else
                let imgname = strftime("%Y%m%d-%H%M%S")
                " this function is from md-img-paste.vim
                let img_write_success = !SaveFileTMP(imgpath, imgname)
                let b:init_last_fig_pasted = [imgname, fig_line]
            endif
            if img_write_success
                let include_ln = '\includegraphics[width=0.7\textwidth]{'.relpath.'/'.imgname.ext.'}'
                if len(caption) || len(label)
                    call setline('.', '\begin{figure} [ht]')
                    call append('.', '\end{figure}')
                    if len(label)
                        call append('.', '\label{'.label.'}')
                        let imgname = label.ext
                    endif
                    if len(caption)
                        call append('.', '\caption{'.caption.'}')
                    endif
                    call append('.', include_ln)
                else
                    call setline('.', include_ln)
                endif
            else
                echoerr 'Not an image or FS error'
            endif
        elseif &filetype == 'markdown'
            call mdip#MarkdownClipboardImage()
        else
            echoerr 'Not a tex file'
        endif
    endfunction

    " }}}
    function! PurgeUnusedImagesTex() abort "{{{
        " purge/delete unused images in the tex
        if &filetype == 'tex'
            let relpath = 'res'
            let imgpath = expand('%:h').'/'.relpath
            let imgs = split(glob(imgpath.'/*.png'), '\n')
            let deathrow = []
            for path in imgs
                let pattern = '\\includegraphics[^\n]*'.path[match(path, '\d\+-\d\+.png'):]
                if !search(pattern)
                    let deathrow += [path]
                endif
            endfor
            if len(deathrow)
                let prompt = "The following will be deleted.\n".join(deathrow, "\n")."\n\n(y/n): "
                let okay = input(prompt)
                if okay == 'y'
                    for path in deathrow
                        silent execute '!del' path
                    endfor
                endif
            endif
        endif
    endfunction

    " }}}

" vim:foldmethod=marker:foldlevel=0:foldtext=MyFold()
