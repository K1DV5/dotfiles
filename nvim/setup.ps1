# cd to the nvim dir and run the followig commands

$deployPath = $HOME + "\AppData\Local\nvim"

cmd /c mklink /D $deployPath\nerdtree_plugin 	$PWD\nerdtree_plugin
cmd /c mklink /D $deployPath\after 		        $PWD\after
cmd /c mklink /D $deployPath\terminal-pane 	    $PWD\terminal-pane
cmd /c mklink    $deployPath\coc-settings.json 	$PWD\coc-settings.json
cmd /c mklink    $deployPath\ginit.vim 		    $PWD\ginit.vim
cmd /c mklink    $deployPath\init.vim 		    $PWD\init.vim
