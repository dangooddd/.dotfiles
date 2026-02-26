#!/usr/bin/env bash

script_dir="$(dirname "$(realpath "$0")")"
cd "$script_dir/../stow"
stow --no-folding -v -t "$HOME" *
