#!/usr/bin/env sh
set -eu

if command -v brew >/dev/null 2>&1; then
    echo "brew found at: $(command -v brew)" >&2
    eval "$(brew shellenv)"
else
    found=0

    for brew_path in \
        "/opt/homebrew/bin/brew" \
        "/home/linuxbrew/.linuxbrew/bin/brew" \
        "$HOME/.linuxbrew/bin/brew"
    do
    if [ -x "$brew_path" ]; then
        echo "brew found at: $brew_path" >&2
        eval "$("$brew_path" shellenv)"
        found=1
        break
    fi
    done

    if [ "$found" -ne 1 ]; then
        echo "brew not found (can't install packages)." >&2
        exit 1
    fi
fi

script_dir="$(cd "$(dirname "$0")" && pwd)"
package_dir="$(cd "$script_dir/../misc/packages" && pwd)"
package_file="${1:-"$package_dir/brew.txt"}"

xargs brew install < "$package_file"
