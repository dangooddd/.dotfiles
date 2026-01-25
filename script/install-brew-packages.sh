#!/usr/bin/env sh

script_dir="$(cd "$(dirname "$0")" && pwd)"
package_dir="$(cd "$script_dir/../misc/packages" && pwd)"

eval "$("$script_dir"/get-brew-shellenv.sh)"
xargs brew install < "$package_dir/brew.txt"
