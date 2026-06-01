#!/usr/bin/env bash

scripts="$(dirname "$(realpath "$0")")"
cd "$scripts/../home"

find "$PWD" \( -type f -o -type l \) -print0 | while read -r -d '' src; do
    dst="${src/"$PWD"/"$HOME"}"
    mkdir -p "$(dirname "$dst")"
    (set -x; cp -f "$src" "$dst")
done
