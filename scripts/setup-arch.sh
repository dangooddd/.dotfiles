#!/usr/bin/env bash

scripts="$(dirname "$(realpath "$0")")"
cd "$scripts"

./sync-dotfiles.sh
./create-aliases.sh arch
./install-yay.sh
./install-arch-packages.sh
./install-flatpak-packages.sh
./install-py-packages.sh
