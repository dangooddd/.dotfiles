#!/usr/bin/env bash

if ! command -v flatpak &> /dev/null; then
    echo "$(basename "$0"): flatpak not found, skip"
    exit
fi

script_dir="$(dirname "$(realpath "$0")")"
cd "$script_dir/../misc/packages"
flatpak mask org.freedesktop.Platform.openh264
xargs flatpak install -y < flatpak.txt
