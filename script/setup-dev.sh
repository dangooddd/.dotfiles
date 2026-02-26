#!/usr/bin/env bash

script_dir="$(dirname "$(realpath "$0")")"
cd "$script_dir"

./install-brew.sh
eval "$(./get-brew-shellenv.sh)"
./install-dev-packages.sh
./install-uv-packages.sh
./stow-dotfiles.sh
