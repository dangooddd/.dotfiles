#!/usr/bin/env bash

# $1 - source
# $2 - destination
function link {
    local src="${1/#$HOME/\~}"
    local dst="${2/#$HOME/\~}"
    
    if [[ -L "$2" ]] && 
        [[ "$(readlink -f "$2")" == "$1" ]]; then
        echo "CHECK: $dst installed"
        return
    fi
    
    if [[ -e "$2" ]]; then
        echo "WARNING: $dst exist (skip)"
        return
    fi

    ln -s "$1" "$2"
    echo "LINK: $dst -> $src"
}

# setup
mkdir -p "$HOME"/.config
mkdir -p "$HOME"/.local/bin
DOTFILES="$(dirname "$(realpath "$0")")"
shopt -s dotglob

#======================================
# ~/.config/*
#======================================
for src in "$DOTFILES"/home/.config/*
do
    link "$src" "$HOME"/.config/"$(basename "$src")" 
done

#======================================
# ~/.local/bin/*
#======================================
for src in "$DOTFILES"/home/.local/bin/*
do
    link "$src" "$HOME"/.local/bin/"$(basename "$src")"
done

#======================================
# ~/*
#======================================
for src in "$DOTFILES"/home/*
do
    if [[ -f "$src" ]]; then
        link "$src" "$HOME"/"$(basename "$src")"
    fi
done
