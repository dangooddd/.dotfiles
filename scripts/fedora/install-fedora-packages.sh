#!/usr/bin/env bash

sudo dnf install $(cat "$HOME"/.dotfiles/packages/fedora.txt) --skip-unavailable
