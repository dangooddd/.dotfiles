#!/usr/bin/env bash

if ! command -v yay &> /dev/null; then
    echo "$(basename "$0"): yay not found, skip"
    exit
fi

if [[ -n "$U" ]]; then
    yay --noconfirm
    exit
fi

packages=(
    uv ty ruff fzf tmux neovim lazygit btop opencode
    ghostty bash-completion pandoc-cli tree-sitter-cli
    flatpak ttc-iosevka wl-clipboard helium-browser-bin
)

yay -S --needed --noconfirm "${packages[@]}"
