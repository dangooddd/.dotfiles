#!/usr/bin/env bash

script_dir="$(dirname "$(realpath "$0")")"
cd "$script_dir/../misc/packages"

if command -v brew &> /dev/null; then
    xargs brew install < brew.txt
else
    echo "$(basename "$0"): brew not found"
fi

