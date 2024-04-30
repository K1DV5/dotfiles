# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc

PS1='\[\e[m\][\[\e[m\]\[\e[35m\]\u\[\e[m\]\[\e[33m\]@\[\e[m\]\[\e[32m\]\h\[\e[m\]:\[\e[36m\]\w\[\e[m\]\[\e[m\]]\[\e[m\]\$ '

export PROJECTSDIR=~/projects
export LOCALVENVDIR=~/.local/venvs

function workon {
    if [ -d $PROJECTSDIR/$1 ]; then
        cd $PROJECTSDIR/$1
        if [ -d .venv ]; then
            local venvdir=./.venv
            if [ -d ./.venv/Scripts ]; then
                local venvdir=$LOCALVENVDIR/$1
            fi
            source $venvdir/bin/activate
            nvim
            deactivate
        else
            nvim
        fi
        cd -
    else
        echo No project named $1
    fi
}
