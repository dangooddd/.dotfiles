#!/usr/bin/env bash

# $1 - source
# $2 - destination
function link {
    local src="${1/#$HOME/\~}"
    local dst="${2/#$HOME/\~}"
    
    if [[ -L "$2" ]] && 
        [[ "$(readlink -f "$2")" == "$1" ]]; then
        echo "CHECK: $dst linked correctly"
        return
    fi
    
    if [[ -e "$2" ]]; then
        echo "WARNING: $dst exist (skip)"
        return
    fi

    ln -s "$1" "$2"
    echo "LINK: $dst -> $src"
}


# create directories that should not be links
mkdir -p "$HOME"/.config

# linking
DOTFILES="$(dirname "$(realpath "$0")")"
shopt -s dotglob

# $HOME/.config/*
for src in "$DOTFILES"/home/.config/*
do
    link "$src" "$HOME"/.config/"$(basename "$src")" 
done

# $HOME/*
for src in "$DOTFILES"/home/*
do
    if [[ -f "$src" ]]; then
        link "$src" "$HOME"/"$(basename "$src")"
    fi
done
