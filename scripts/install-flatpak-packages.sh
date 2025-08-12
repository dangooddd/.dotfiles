#!/usr/bin/env bash

flatpak mask org.freedesktop.Platform.openh264
flatpak install $(cat "$HOME"/.dotfiles/packages/flatpak.txt)
