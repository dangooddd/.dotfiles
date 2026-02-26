#!/usr/bin/env bash

script_dir="$(dirname "$(realpath "$0")")"
cd "$script_dir/../misc/packages"

for pkg in $(cat uv.txt); do
    uv tool install "$pkg"
done
