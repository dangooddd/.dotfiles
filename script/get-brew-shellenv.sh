#!/usr/bin/env bash

if command -v brew &>/dev/null; then
    brew shellenv
else
    if [[ -x /opt/homebrew/bin/brew ]]; then
        /opt/homebrew/bin/brew shellenv
    elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
        /home/linuxbrew/.linuxbrew/bin/brew shellenv
    elif [[ -x ${HOME}/.linuxbrew/bin/brew ]]; then
        "${HOME}/.linuxbrew/bin/brew" shellenv
    fi
fi
