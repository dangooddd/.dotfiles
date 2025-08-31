#!/usr/bin/env bash

sudo pacman -S --noconfirm --needed base-devel rustup
rustup toolchain install stable

cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
