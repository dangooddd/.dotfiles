#!/usr/bin/env bash

if ! command -v yay &> /dev/null; then
    sudo pacman -S --noconfirm --needed git base-devel less 
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
fi
