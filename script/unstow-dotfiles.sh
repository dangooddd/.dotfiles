#!/usr/bin/env bash

if ! command -v stow &> /dev/null; then
    echo "$(basename "$0"): stow not found, skip"
    exit
fi

script_dir="$(dirname "$(realpath "$0")")"
cd "$script_dir/../stow"
stow --no-folding -D -v -t "$HOME" *
