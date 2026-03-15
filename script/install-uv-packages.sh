#!/usr/bin/env bash

if ! command -v uv &>/dev/null; then
    echo "$(basename "$0"): uv not found, skip"
    exit
fi

script_dir="$(dirname "$(realpath "$0")")"
cd "$script_dir/../misc/packages"

while IFS= read -r pkg; do
    uv tool install "$pkg"
done <uv.txt
