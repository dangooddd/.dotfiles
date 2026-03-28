#!/usr/bin/env bash

if ! command -v brew &>/dev/null; then
    echo "$(basename "$0"): brew not found, skip"
    exit
fi

packages=(
    git python uv font-iosevka
    fzf nvim lazygit tree-sitter-cli
    anomalyco/tap/opencode bash bash-completion@2
    ghostty google-chrome telegram
)

brew install "${packages[@]}"
