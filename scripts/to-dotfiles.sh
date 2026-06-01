#!/usr/bin/env bash

[[ -e "$1" ]] || exit 1
scripts="$(dirname "$(realpath "$0")")"
src="$(realpath -s "$1")"

case "$src" in
    "$HOME"/*) rel="${src#"$HOME"/}" ;;
    *) exit 1 ;;
esac

dst="$scripts/../home/$rel"
mkdir -p "$(dirname "$dst")"
cp -aL "$src" "$dst"
