#!/usr/bin/env sh

script_dir="$(cd "$(dirname "$0")" && pwd)"
package_dir="$(cd "$script_dir/../misc/packages" && pwd)"

for pkg in $(cat "$package_dir/uv.txt"); do
  uv tool install "$pkg"
done
