#!/usr/bin/env bash

if ! command -v npm &> /dev/null; then
    echo "$(basename "$0"): npm not found, skip"
    exit
fi

if [[ -n "$U" ]]; then
    command -v pi &> /dev/null && pi update --all
    exit
fi

npm config set prefix "${HOME}/.local"
npm config set fund false
npm install -g --ignore-scripts @earendil-works/pi-coding-agent

cd "${HOME}/.pi/agent/extensions" || exit
npm install
