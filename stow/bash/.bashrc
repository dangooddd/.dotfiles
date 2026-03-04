################################################################################
# General
################################################################################
shopt -s dotglob
shopt -s histappend
set -o emacs

if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x $HOME/.linuxbrew/bin/brew ]]; then
    eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
fi

HISTSIZE=10000
HISTFILESIZE=10000
HISTCONTROL=ignoreboth:erasedups

if [[ -n $HOMEBREW_PREFIX ]]; then
    PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
fi

PATH="$PATH:$HOME/.local/bin:$HOME/.cargo/bin"
export PATH

export FZF_DEFAULT_OPTS="
	--color=fg:#908caa,bg:#191724,hl:#ebbcba
	--color=fg+:#e0def4,bg+:#403d52,hl+:#ebbcba
	--color=border:#6e6a86,header:#31748f,gutter:#191724
	--color=spinner:#f6c177,info:#9ccfd8
	--color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa
    --layout=reverse --height=15 --border=sharp --ansi"

export LESS="--tilde -RFXS"
export PYTHONSTARTUP="$HOME/.pythonstartup.py"
export CARGO_HOME="$HOME/.cargo"
export PAGER="less"
export EDITOR="nvim"
export VIRTUAL_ENV_DISABLE_PROMPT=1

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"


################################################################################
# Aliases and functions
################################################################################
function ls {
    command ls --group-directories-first \
               --color=auto "$@"
}

function la {
    ls -Av "$@"
}

function cd {
    command cd "$@" || return
    la
}


################################################################################
# Init
################################################################################
if command -v dircolors &> /dev/null; then
    eval "$(dircolors -b)"
fi

if command -v fzf &>/dev/null; then
    eval "$(fzf --bash)"
fi

if [[ -z $SSH_AUTH_SOCK ]]; then
    eval "$(ssh-agent -s)" &> /dev/null
fi


################################################################################
# Sourcing
################################################################################
if [[ -r $HOME/.bashrc.local ]]; then
    source "$HOME/.bashrc.local"
fi

if [[ -r $CARGO_HOME/env ]]; then
    source "$CARGO_HOME/env"
fi

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion 
elif [[ -r /etc/bash_completion ]]; then
    source /etc/bash_completion
elif [[ -r $HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh ]]; then
    source "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
fi
