#!/usr/bin/env sh

if command -v brew >/dev/null 2>&1; then
    brew shellenv
else
    for brew_path in \
        "/opt/homebrew/bin/brew" \
        "/home/linuxbrew/.linuxbrew/bin/brew" \
        "$HOME/.linuxbrew/bin/brew"
    do
    if [ -x "$brew_path" ]; then
        "$brew_path" shellenv
    fi
    done
fi
