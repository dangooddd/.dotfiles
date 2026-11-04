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
    git python uv ty ruff btop fzf nvim opencode lazygit
    pandoc tree-sitter-cli bash bash-completion@2 ghostty
    helium-browser telegram font-iosevka
)

brew install -y "${packages[@]}"
