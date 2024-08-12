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

# directory remove
# if directory is link, delete link file
# (linked directory will be fine)
function ddir {
    if [ -d "$1" ]; then
        if [ -L "$1" ]; then
            rm "$1"
        else
            rm -rf "$1"
        fi
        colored "red" "# "
        printf "Remove %s\n" "$1"
    fi
}

# directory installation with backup if already exist
function dinstall {
    # $1 - src, $2 - dst, $3 - back

    if [ -d "$2" ]; then
        if [ -d "$3" ]; then
            ddir "$3"
        fi
        mv "$2" "$3"
        colored "yellow" "* "
        printf "Move %s to %s\n" "$2" "$3"
    fi

    colored "green" "+ "
    printf "Link %s to %s\n\n" "$1" "$2"
    ln -s "$1" "$2"
}

# file installation with backup if already exist
function finstall {
    # $1 - src, $2 - dst, $3 - back
    if [ -f "$2" ] || [ -L "$2" ]; then
        if [ -f "$3" ] || [ -L "$3" ]; then
            rm "$3"
            colored "red" "# "
            printf "Remove %s\n" "$3"
        fi
        mv "$2" "$3"
        colored "yellow" "* "
        printf "Move %s to %s\n" "$2" "$3"
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
    mkdir -p "$dotfiles"/.backup/.config
    shopt -s dotglob
    
    # .config
    for src in "$dotfiles"/.config/*
    do
        local name
        name="$(basename "$src")"

        if [ -d "$src" ]; then
            dinstall "$src" \
                     "$HOME"/.config/"$name" \
                     "$dotfiles"/.backup/.config/"$name"
        fi

        if [ -f "$src" ] || [ -L "$src" ]; then
            finstall "$src" \
                     "$HOME"/.config/"$name" \
                     "$dotfiles"/.backup/.config/"$name"
        fi
    done

    # .wallpapers
    dinstall "$dotfiles"/.wallpapers \
             "$HOME"/.wallpapers \
             "$dotfiles"/.backup/.wallpapers

    colored "magenta" "[ "
    colored "red" "Dotfiles installed!"
    colored "magenta" " ]\n"
}

# install
case "$1" in
    *) linkFiles ;;
esac
