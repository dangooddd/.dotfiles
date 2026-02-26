#!/usr/bin/env bash

script_dir="$(dirname "$(realpath "$0")")"
cd "$script_dir"

./install-yay.sh
./install-arch-packages.sh
./install-flatpak-packages.sh
./install-uv-packages.sh
./stow-dotfiles.sh
