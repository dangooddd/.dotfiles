#!/usr/bin/env bash

if ! command -v yay &>/dev/null; then
    sudo pacman -S --noconfirm --needed git base-devel
    yay="$(mktemp -d /tmp/yay-XXXXXXXX)"
    git clone https://aur.archlinux.org/yay.git "$yay"
    cd "$yay"
    makepkg -si
fi
