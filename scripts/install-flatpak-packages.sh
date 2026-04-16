#!/usr/bin/env bash

if ! command -v flatpak &> /dev/null; then
    echo "$(basename "$0"): flatpak not found, skip"
    exit
fi

packages=(
    org.telegram.desktop
    com.obsproject.Studio
    com.github.flxzt.rnote
    net.davidotek.pupgui2
    com.valvesoftware.Steam
)

flatpak mask org.freedesktop.Platform.openh264
flatpak install -y "${packages[@]}"
