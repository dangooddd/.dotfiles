#!/usr/bin/env bash

if ! command -v npm &> /dev/null; then
    echo "$(basename "$0"): npm not found, skip"
    exit
fi

if [[ -n "$U" ]]; then
    opencode upgrade
    exit
fi

npm config set prefix "${HOME}/.local"
npm config set fund false
npm install -g --allow-scripts=@opencode/cli @opencode-ai/cli
