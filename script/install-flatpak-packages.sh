#!/usr/bin/env bash

script_dir="$(dirname "$(realpath "$0")")"
cd "$script_dir/../misc/packages"
flatpak mask org.freedesktop.Platform.openh264
xargs flatpak install -y < flatpak.txt
