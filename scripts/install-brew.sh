#!/usr/bin/env bash

if ! command -v brew &>/dev/null; then
    NONINTERACTIVE=1 bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
