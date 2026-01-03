#!/usr/bin/env sh

flatpak mask org.freedesktop.Platform.openh264
xargs flatpak install -y < "$HOME"/.dotfiles/misc/packages/flatpak.txt 
