#!/usr/bin/env bash

if ! command -v brew &>/dev/null; then
    echo "$(basename "$0"): brew not found, skip"
    exit
fi

packages=(
    fzf nvim lazygit tree-sitter-cli
    anomalyco/tap/opencode bash bash-completion@2
    git python uv font-iosevka-term-nerd-font
    ghostty google-chrome telegram
)

brew install "${packages[@]}"
