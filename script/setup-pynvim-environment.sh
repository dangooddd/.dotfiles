#!/usr/bin/env sh

script_dir="$(cd "$(dirname "$0")" && pwd)"
package_dir="$(cd "$script_dir/../misc/packages" && pwd)"

eval "$("$script_dir"/get-brew-shellenv.sh)"
uv venv --clear "$HOME"/.venv_nvim
. "$HOME"/.venv_nvim/bin/activate
xargs uv pip install < "$package_dir/pynvim.txt"
