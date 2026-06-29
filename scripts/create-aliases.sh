#!/usr/bin/env bash

if [[ -n "$U" ]]; then
    exit
fi

scripts="$(dirname "$(realpath "$0")")"
update="U=1 ${scripts}/setup-arch.sh"
file="${HOME}/.bashrc.local"

case "$1" in
    dev) update="U=1 ${scripts}/setup-dev.sh" ;;
    arch) update="U=1 ${scripts}/setup-arch.sh" ;;
    macos) update="U=1 ${scripts}/setup-macos.sh" ;;
    *) ;;
esac

touch "$file"
cat <<< "# vim: set ft=bash:
alias sync-dotfiles=\"${scripts}/sync-dotfiles.sh\"
alias from-dotfiles=\"${scripts}/from-dotfiles.sh\"
alias to-dotfiles=\"${scripts}/to-dotfiles.sh\"
alias copy-dotfiles-remote=\"${scripts}/copy-dotfiles-remote.sh\"
alias copy-dotfiles-docker=\"${scripts}/copy-dotfiles-docker.sh\"
alias update=\"$update\"
complete -F _docker_container_completion copy-dotfiles-docker
$(cat "$file")" > "$file"
