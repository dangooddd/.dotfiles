# init.sh

# no new line if var unset (on start of terminal)
# new line if var is set
precmd() {
    if [[ -z $NEW_LINE_BEFORE_PROMPT ]]; then
        NEW_LINE_BEFORE_PROMPT=1
    else
        echo
    fi
}

# init cli tools
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

export EDITOR="hx"
export LESS="--tilde -RXS"
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgrep.conf"

fast-theme -q XDG:kanagawa
