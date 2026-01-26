#!/usr/bin/env sh

dotfiles="$(cd "$(dirname "$0")/../" && pwd)"
remote="$1"

rsync -avz \
  --exclude='*.jpg' \
  --exclude='*.png' \
  --exclude='.git/' \
  "$dotfiles" "$remote"

