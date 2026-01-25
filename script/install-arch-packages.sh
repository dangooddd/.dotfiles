#!/usr/bin/env sh

script_dir="$(cd "$(dirname "$0")" && pwd)"
package_dir="$(cd "$script_dir/../misc/packages" && pwd)"

yay -S --needed --noconfirm - < "$package_dir/arch.txt"
