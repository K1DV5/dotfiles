" ============================================================================
" File:        execute_menuitem.vim
" Description: plugin for NERD Tree that provides an execute menu item, that
"              executes system default application for file or directory
" Maintainer:  Ivan Tkalin <itkalin at gmail dot com>
" Last Change: 27 May, 2010
" ============================================================================
if exists("g:loaded_nerdtree_shell_exec_menuitem")
  finish
endif

let g:loaded_nerdtree_shell_exec_menuitem = 1
let s:haskdeinit = system("ps -e") =~ 'kdeinit'
let s:hasdarwin = system("uname -s") =~ 'Darwin'

call NERDTreeAddMenuItem({
      \ 'text': '(x)ecute',
      \ 'shortcut': 'x',
      \ 'callback': 'NERDTreeExecute' })

function! NERDTreeExecute()
  let l:oldssl=&shellslash
  set noshellslash
  let treenode = g:NERDTreeFileNode.GetSelected()
  let path = treenode.path.str()
  let isdir = treenode.path.isDirectory

  if has("gui_running")
    let args = shellescape(path,1)." &"
  else
    let args = shellescape(path,1)." > /dev/null"
  end

  if isdir
	execute "silent !explorer ".shellescape(path,1)
  else
	exe "silent !explorer ".shellescape(path,1)
  endif
  let &shellslash=l:oldssl
  redraw!
endfunction
