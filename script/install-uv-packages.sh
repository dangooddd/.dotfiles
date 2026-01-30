#!/usr/bin/env sh

script_dir="$(cd "$(dirname "$0")" && pwd)"
package_dir="$(cd "$script_dir/../misc/packages" && pwd)"

eval "$("$script_dir"/get-brew-shellenv.sh)"
xargs uv tool install < "$package_dir/uv.txt"
