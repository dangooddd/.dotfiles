#!/usr/bin/env bash

script_dir="$(dirname "$(realpath "$0")")"
remote="$1"
cd "$script_dir/../"

rsync -avz \
  --exclude='*.jpg' \
  --exclude='*.png' \
  "$(pwd)" "$remote"

