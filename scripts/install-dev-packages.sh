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
    uv fzf tmux nvim lazygit git
    tree-sitter-cli npm imagemagick
    "anomalyco/tap/opencode"
)

brew install -y "${packages[@]}"
