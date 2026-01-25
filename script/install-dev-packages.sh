#!/usr/bin/env sh

script_dir="$(cd "$(dirname "$0")" && pwd)"
package_dir="$(cd "$script_dir/../misc/packages" && pwd)"

"$script_dir"/install-brew-packages.sh "$package_dir/dev.txt"
