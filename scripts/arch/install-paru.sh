#!/usr/bin/env bash

sudo pacman -S --needed base-devel
sudo pacman -S rustup
rustup toolchain install stable

cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
