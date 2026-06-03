#!/usr/bin/env bash

home="$(dirname "$(dirname "$(realpath "$0")")")/home"

for arg in "$@"; do
    dst="$(realpath "$arg")"

    if [[ "$dst" == "$HOME"/* ]]; then
        rel="${dst#"$HOME"/}"
    else
        continue
    fi

    src="$home/$rel"

    if [[ ! -e "$src" ]]; then
        continue
    fi

    if [[ -d "$src" ]]; then
        src="${src}/."
    fi

    mkdir -p "$(dirname "$dst")"
    (set -x; cp -r "$src" "$dst")
done

