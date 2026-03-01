#!/usr/bin/env bash

if ! command -v uv &> /dev/null; then
    echo "$(basename "$0"): uv not found, skip"
    exit
fi

script_dir="$(dirname "$(realpath "$0")")"
cd "$script_dir/../misc/packages"

for pkg in $(cat uv.txt); do
    uv tool install "$pkg"
done
