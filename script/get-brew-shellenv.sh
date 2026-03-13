#!/usr/bin/env bash

if command -v brew >/dev/null 2>&1; then
    brew shellenv
else
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [[ -x ${HOME}/.linuxbrew/bin/brew ]]; then
        eval "$("${HOME}/.linuxbrew/bin/brew" shellenv)"
    fi
fi
