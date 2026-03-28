#!/usr/bin/env bash

if ! command -v yay &>/dev/null; then
    echo "$(basename "$0"): yay not found, skip"
    exit
fi

packages=(
    uv fzf tmux nvim opencode
    lazygit flatpak npm ghostty
    ttc-iosevka wl-clipboard bash-completion
    tree-sitter-cli qbittorrent google-chrome
)

yay -S --needed --noconfirm "${packages[@]}"
