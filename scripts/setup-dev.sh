#!/usr/bin/env bash

scripts="$(dirname "$(realpath "$0")")"
cd "$scripts"

./sync-dotfiles.sh
./create-aliases.sh dev
./install-brew.sh
eval "$(./get-brew-shellenv.sh)"
./install-dev-packages.sh
./install-py-packages.sh
