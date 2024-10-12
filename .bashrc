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

function workon {
    if [ ! -d $1 ]; then
        read -p "No project named $1. Create it? \(y\)/n: " yn
        if [ "$yn" == "y" ]; then
            echo "Creating dir $1"
            mkdir -p $1
        else
            return
        fi
    fi
    cd $1
    # Look for virtual envs up tree
    local DIR=$(pwd)
    while [ ! -z "$DIR" ] && [ ! -d "$DIR/.venv" ]; do
        DIR="${DIR%\/*}"
    done
    local inVenv=0
    if [ -d $DIR/.venv/Scripts ]; then
        source $DIR/.venv/Scripts/activate
        inVenv=1
    elif [ -d $DIR/.venv/bin ]; then
        source $DIR/.venv/bin/activate
        inVenv=1
    fi
    nvim
    if [ $inVenv == 1 ]; then
        deactivate
    fi
    cd -
}
