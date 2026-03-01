#!/usr/bin/env bash

if ! command -v rsync &> /dev/null; then
    echo "$(basename "$0"): rsync not found, skip"
    exit
fi

script_dir="$(dirname "$(realpath "$0")")"
remote="$1"
cd "$script_dir/../"

rsync -avz \
  --exclude='*.jpg' \
  --exclude='*.png' \
  "$(pwd)" "$remote"
