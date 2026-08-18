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
    uv fzf tmux nvim lazygit tree-sitter-cli
    flatpak npm ghostty wl-clipboard
    ttc-iosevka bash-completion imagemagick
    helium-browser-bin
)

yay -S --needed --noconfirm "${packages[@]}"
