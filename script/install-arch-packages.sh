#!/usr/bin/env bash

if ! command -v yay &> /dev/null; then
    echo "$(basename "$0"): yay not found, skip"
    exit
fi

script_dir="$(dirname "$(realpath "$0")")"
cd "$script_dir/../misc/packages"
yay -S --needed --noconfirm - < arch.txt
