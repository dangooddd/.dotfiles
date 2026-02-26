#!/usr/bin/env bash

script_dir="$(dirname "$(realpath "$0")")"
cd "$script_dir/../misc/packages"
yay -S --needed --noconfirm - < arch.txt
