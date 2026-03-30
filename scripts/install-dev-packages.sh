#!/usr/bin/env bash

if ! command -v brew &>/dev/null; then
    echo "$(basename "$0"): brew not found, skip"
    exit
fi

packages=(
    uv fzf tmux nvim lazygit
    tree-sitter-cli npm
)

brew install "${packages[@]}"
