#!/usr/bin/env bash

script_dir="$(dirname "$(realpath "$0")")"
cd "$script_dir"

./sync-dotfiles.sh
./create-aliases.sh
./install-yay.sh
./install-arch-packages.sh
./install-flatpak-packages.sh
./install-py-packages.sh
./install-js-packages.sh
