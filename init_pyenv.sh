#!/bin/bash

CURRENT_DIR=$(pwd)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT_DIR="$SCRIPT_DIR/.."
PYTHON_VERSION=3.9.5

if [ $SUDO_USER ] && [ "$( whoami )" == "root" ];
then

echo sudo_user: $SUDO_USER
echo user: `whoami`
# restart this script whithout root rights
sudo -u ${SUDO_USER} $SCRIPT_DIR/init_pyenv.sh

exit 0
fi

echo sudo_user: $SUDO_USER
echo user: `whoami`

curl -L 'https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer' | bash

function add_to_bashrc {
    count=$(grep -c "$1" ~/.bashrc)
    if [[ $count == 0 ]]; then
        echo -e $@ >> ~/.bashrc
        echo add $@
    else
        echo pyenv was installed earlier
        echo "try grep -c \"$1\" ~/.bashrc  count: $count"
    fi
}

# set environment vars PYENV_ROOT and add $PYENV_ROOT/bin to $PATH:
add_to_bashrc '#alphaopen media settings start'
add_to_bashrc 'export PYENV_ROOT="$HOME/.pyenv"'
add_to_bashrc 'export PATH="$PYENV_ROOT/bin:$PATH"'

# add pyenv init to shell:
add_to_bashrc '[ command -v pyenv 1>/dev/null 2>&1 ] || eval "$(pyenv init --path)" && eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init -)"'
add_to_bashrc '#alphaopen media settings end'

# reload shell:
. ~/.bashrc

#Install python:
pyenv install -s $PYTHON_VERSION

#Install python for project directory:
cd "$SCRIPT_DIR/.."
PROJECT_NAME=$(echo `git config --get remote.origin.url` | sed -rn 's/^.*\/(.*)\.git$/\1/p')
pyenv virtualenv $PYTHON_VERSION pyenv-$PROJECT_NAME-$PYTHON_VERSION
pyenv local pyenv-$PROJECT_NAME-$PYTHON_VERSION
python -m pip install -r $PROJECT_ROOT_DIR/contrib/requirements.txt
cd "$CURRENT_DIR"
