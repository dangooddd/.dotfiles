#!/usr/bin/env bash

if ! command -v brew &> /dev/null; then
    echo "$(basename "$0"): brew not found, skip"
    exit
fi

if [[ -n "$U" ]]; then
    brew upgrade -y
    exit
fi

packages=(
    uv ty ruff fzf tmux nvim lazygit git
    btop opencode tree-sitter-cli 
)

brew install -y "${packages[@]}"
