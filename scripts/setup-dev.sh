#!/usr/bin/env bash

script_dir="$(dirname "$(realpath "$0")")"
cd "$script_dir"

./sync-dotfiles.sh
./create-aliases.sh
./install-brew.sh
eval "$(./get-brew-shellenv.sh)"
./install-dev-packages.sh
./install-py-packages.sh
./install-js-packages.sh
