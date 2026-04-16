#!/usr/bin/env bash

if ! command -v yay &> /dev/null; then
    echo "$(basename "$0"): yay not found, skip"
    exit
fi

packages=(
    uv fzf tmux nvim lazygit
    flatpak npm ghostty wl-clipboard
    ttc-iosevka bash-completion imagemagick
    tree-sitter-cli qbittorrent google-chrome
)

yay -S --needed --noconfirm "${packages[@]}"
