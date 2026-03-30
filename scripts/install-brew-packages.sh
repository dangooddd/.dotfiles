#!/usr/bin/env bash

if ! command -v brew &>/dev/null; then
    echo "$(basename "$0"): brew not found, skip"
    exit
fi

packages=(
    git python uv font-iosevka npm
    fzf nvim lazygit tree-sitter-cli
    bash bash-completion@2 ghostty
    google-chrome telegram
)

brew install "${packages[@]}"
