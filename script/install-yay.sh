#!/usr/bin/env sh

sudo pacman -S --noconfirm --needed git base-devel less 
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
