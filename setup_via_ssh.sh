#!/usr/bin/bash

set -eo pipefail

usage() {
    echo "./setup_via_ssh HOST"
    echo "HOST hostname to ssh to"
    exit 1
}

HOSTNAME=$1
if [ -z "$HOSTNAME" ]; then
    usage
fi

ssh "$HOSTNAME" << 'SETUP_SCRIPT'
#!/usr/bin/bash
set -e 

if [ ! -d "$HOME/dotfiles-public" ]; then
    git clone https://github.com/rrenomeron/dotfiles-public
else
    echo "Dotfiles already exist"
fi

if [ -x "$HOME/dotfiles-public/setup_bashrc.sh" ]; then
    $HOME/dotfiles-public/setup_bashrc.sh
else
    echo "No Bash setup script in dotfiles directory"
    exit 1
fi

SETUP_SCRIPT