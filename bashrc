# ignore duplicate history entries
export HISTCONTROL=ignorespace:erasedups

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:" ]]
then
    PATH="$HOME/.local/bin:$PATH"
fi
export PATH

function workon {
    if [ ! -d $1 ]; then
        read -p "No project named $1. Create it? (y)/n: " yn
        if [ "$yn" == "n" ]; then
            return
        fi
        echo "Creating dir $1"
        mkdir -p $1
    fi
    cd $1
    # Look for virtual envs up tree
    local DIR=$(pwd)
    while [ ! -z "$DIR" ] && [ ! -d "$DIR/.venv" ]; do
        DIR="${DIR%\/*}"
    done
    local inVenv=0
    if [ -d $DIR/.venv/bin ]; then
        source $DIR/.venv/bin/activate
        inVenv=1
    fi
    PATH="$HOME/.local/npm-g/bin:$HOME/go/bin:$PATH" nvim
    if [ $inVenv == 1 ]; then
        deactivate
    fi
    cd -
}

# activated in .bashrc with:
# . ~/bashrc 2>/dev/null

# vim:ft=bash
