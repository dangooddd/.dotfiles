#!/usr/bin/env bash

if ! command -v bun &>/dev/null; then
    echo "$(basename "$0"): bun not found, skip"
    exit
fi

packages=(@mariozechner/pi-coding-agent)

bun install -g "${packages[@]}"
