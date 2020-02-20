

" Builtins:
	"set font
	" silent! Guifont! Hack NF:h10.5
    Guifont! Consolas NF:h10.5
	" increase the space between lines
	" call GuiLinespace(1)
    " disable the gui tabline
    GuiTabline 0
    " disable the gui popup menu
    GuiPopupmenu 0

	if argc() == 0
		" start maximized
		" call GuiWindowMaximized(1)
		" start fullscreen
		call GuiWindowFullScreen(1)
	endif

" Functions:
	" toggle full screen
	function! ToggleFS()
		if g:GuiWindowFullScreen == 0
			call GuiWindowFullScreen(1)
            " since you're commiting that you'll stay,
            CocEnable
		else
			call GuiWindowFullScreen(0)
		endif
	endfunction

" Mappings:
	"toggle fullscreen
	noremap <F11> <cmd>call ToggleFS()<cr>

