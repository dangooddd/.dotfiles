#!/usr/bin/env bash

# colored output
function colored {
    local color
    local end
    case "$1" in
        "red") color="\e[0;31m";;
        "green") color="\e[0;32m";;
        "magenta") color="\e[0;35m";;
        "yellow") color="\e[1;33m";;
    esac
    end="\e[0m"
    printf "$color$2$end"
}

# link file or directory
# $1 - src, $2 - dst
function link {
    if [[ -L "$2" ]]; then
        rm "$2"
        colored "red" "* "
        printf "Remove %s (link)\n" "$2"
    fi

    if [[ -e "$2" ]]; then
        trash-put "$2"
        colored "yellow" "* "
        printf "Move %s to trash\n" "$2"
    fi

    colored "green" "+ "
    printf "Link %s to %s\n\n" "$1" "$2"
    ln -s "$1" "$2"
}

# link configuration files
function linkFiles {
    colored "magenta" "\n[ "
    colored "red" "Installing dangooddd dotfiles"
    colored "magenta" " ]\n\n"

    # setup
    local dotfiles
    dotfiles="$(dirname "$(readlink -f "$0")")"
    shopt -s dotglob
    
    # .config
    for src in "$dotfiles"/home/.config/*
    do
        link "$src" \
             "$HOME"/.config/"$(basename "$src")"
    done

    # single files
    link "$dotfiles"/home/.bashrc \
         "$HOME"/.bashrc

    colored "magenta" "[ "
    colored "red" "Dotfiles installed!"
    colored "magenta" " ]\n"
}

# install
case "$1" in
    *) linkFiles ;;
esac
