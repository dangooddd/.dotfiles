#!/usr/bin/env bash

script_dir="$(dirname "$(realpath "$0")")"
cd "$script_dir/../home"

find "$PWD" \( -type f -o -type l \) -print0 | while read -r -d '' src; do
    dst="${src/"$PWD"/"$HOME"}"
    mkdir -p "$(dirname "$dst")"
    (set -x; ln -sfn "$src" "$dst")
done
