#!/usr/bin/env bash

script_dir="$(dirname "$(realpath "$0")")"
cd "$script_dir/../home"

find "$PWD" \( -type f -o -type l \) -print0 | while IFS= read -r -d '' src; do
    dst="${src/"$PWD"/"$HOME"}"
    (set -x; ln -sfn "$src" "$dst")
done
