#!/usr/bin/env bash

if command -v brew &>/dev/null; then
    brew shellenv
    exit
fi

for brew_path in \
    /opt/homebrew/bin/brew \
    /home/linuxbrew/.linuxbrew/bin/brew \
    ${HOME}/.linuxbrew/bin/brew
do
    if [[ -x $brew_path ]]; then
        "$brew_path" shellenv
        exit
    fi
done
