#!/usr/bin/env bash

scripts="$(dirname "$(realpath "$0")")"
file="${HOME}/.bashrc.local"

touch "$file"
cat <<< "# vim: set ft=bash:
alias sync-dotfiles=\"${scripts}/sync-dotfiles.sh\"
alias to-dotfiles=\"${scripts}/to-dotfiles.sh\"
alias copy-dotfiles-remote=\"${scripts}/copy-dotfiles-remote.sh\"
alias copy-dotfiles-docker=\"${scripts}/copy-dotfiles-docker.sh\"
complete -F _docker_container_completion copy-dotfiles-docker
$(cat "$file")" > "$file"
