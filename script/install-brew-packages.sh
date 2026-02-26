#!/usr/bin/env sh

script_dir="$(cd "$(dirname "$0")" && pwd)"
package_dir="$(cd "$script_dir/../misc/packages" && pwd)"

if command -v brew &> /dev/null; then
    xargs brew install < "$package_dir/brew.txt"
else
    echo "$(basename "$0"): brew not found"
fi

