#!/usr/bin/env bash

if ! command -v npm &> /dev/null; then
    echo "$(basename "$0"): npm not found, skip"
    exit
fi

packages=(@mariozechner/pi-coding-agent)

npm config set prefix "${HOME}/.local"
npm config set fund false
npm install -g "${packages[@]}"
