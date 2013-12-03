#!/bin/bash
#
# Setup on a fresh computer.
#

function _setup() {

    local setup_dir = '~/dotfiles/'
    declare -a symoblic_links=(.ackrc .aliases .bashrc .curlrc .exports .exports .freebsd .functions .gitattributes .gitconfig .inputrc .linux .osx .profile .pythonrc.py .vimrc .wgetrc .xmobarrc .Xresources .zshrc .vim .xmonad)

    for file in ${symoblic_links[@]}
    do
        if [ -e $file ]; then
            print $file
        fi
    done
}

_setup "$@"
