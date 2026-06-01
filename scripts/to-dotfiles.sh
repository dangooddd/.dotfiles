#!/usr/bin/env bash

home="$(dirname "$(dirname "$(realpath "$0")")")/home"

for arg in "$@"; do
    [[ -e "$arg" ]] || exit 1
    src="$(realpath "$arg")"

    case "$src" in
        "$HOME"/*) rel="${src#"$HOME"/}" ;;
        *) exit 1 ;;
    esac

    if [[ -d "$src" ]]; then
        src="${src}/."
    fi

    dst="$home/$rel"
    mkdir -p "$(dirname "$dst")"
    (set -x; cp -r "$src" "$dst")
done
