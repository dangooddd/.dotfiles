#!/usr/bin/env bash

script_dir="$(dirname "$(realpath "$0")")"
file_path="${HOME}/.bashrc.local"

touch "$file_path"
cat <<< "# vim: set ft=bash:
alias sync-dotfiles=\"${script_dir}/sync-dotfiles.sh\"
alias copy-dotfiles-remote=\"${script_dir}/copy-dotfiles-remote.sh\"
alias copy-dotfiles-docker=\"${script_dir}/copy-dotfiles-docker.sh\"
$(cat "$file_path")" > "$file_path"
