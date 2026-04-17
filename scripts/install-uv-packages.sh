#!/usr/bin/env bash

if ! command -v uv &> /dev/null; then
    echo "$(basename "$0"): uv not found, skip"
    exit
fi

packages=(jupytext ty ruff ddgs "markitdown[all]")

for pkg in "${packages[@]}"; do
    uv tool install --upgrade "$pkg"
done
