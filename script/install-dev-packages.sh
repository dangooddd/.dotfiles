#!/usr/bin/env bash

if ! command -v brew &> /dev/null; then
    echo "$(basename "$0"): brew not found, skip"
    exit
fi

script_dir="$(dirname "$(realpath "$0")")"
cd "$script_dir/../misc/packages"
xargs brew install < dev.txt
