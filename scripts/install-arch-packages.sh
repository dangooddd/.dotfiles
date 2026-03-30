#!/usr/bin/env bash

if ! command -v yay &>/dev/null; then
    echo "$(basename "$0"): yay not found, skip"
    exit
fi

packages=(
    uv fzf tmux nvim lazygit
    ttc-iosevka bash-completion
    flatpak npm ghostty wl-clipboard
    tree-sitter-cli qbittorrent google-chrome
)

yay -S --needed --noconfirm "${packages[@]}"
