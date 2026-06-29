#!/usr/bin/env bash

if ! command -v rsync &> /dev/null; then
    echo "$(basename "$0"): rsync not found, skip"
    exit
fi

scripts="$(dirname "$(realpath "$0")")"
remote="$1"
cd "$scripts/../"

rsync -avz \
    --exclude='*.jpg' \
    --exclude='*.png' \
    "$PWD" "$remote"
