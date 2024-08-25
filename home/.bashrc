# .bashrc

# == Global definitions ==
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi


# == Path == 
function addPath {
    if ! [[ "$PATH" =~ "$1:" ]]; then
        PATH="$1:$PATH"
        export PATH
    fi
}
addPath "$HOME/.local/bin"
addPath "$HOME/.cargo/bin"


# == Bash options ==
export HISTSIZE=500
export HISTFILESIZE=10000
export HISTTIMEFORMAT="%F %T "
export HISTCONTROL="erasedups:ignoreboth"
shopt -s histappend
shopt -s checkwinsize
shopt -s expand_aliases


# == Aliases and functions ==
function auto-venv-toggle {
    if [[ -z "$__auto_venv_stop" ]]; then
        __auto_venv_stop="Y"
    else
        __auto_venv_stop=""
    fi
}

function venv-update {
    local venv="./.venv/bin/activate"
    if [[ -z "$VIRTUAL_ENV" ]] &&
        [[ -e "$venv" ]]; then
        . "$venv"
    fi

    if ! [[ -z "$VIRTUAL_ENV" ]] &&
        [[ "$(dirname "$VIRTUAL_ENV")" != "$PWD" ]] &&
        [[ -e "$venv" ]]; then
        deactivate
        . "$venv"
    fi

    if ! [[ -z "$VIRTUAL_ENV" ]] &&
        ! [[ "$PWD" =~ "$(dirname "$VIRTUAL_ENV")" ]]; then
        deactivate
    fi
}

function venv-activate {
    local venv="./.venv/bin/activate"
    if ! [[ -e "$venv" ]]; then
        echo "venv-activate: can not find venv"
        return 1
    fi

    if [[ -z "$VIRTUAL_ENV" ]]; then
        . "$venv"
    else
        deactivate
        . "$venv"
    fi

    return 0
}

function venv-deactivate {
    if ! [[ -z "$VIRTUAL_ENV" ]]; then
        deactivate
    fi
}

function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        if command -v zoxide &> /dev/null; then
            zoxide add "$cwd"
        fi
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

if command -v trash &> /dev/null; then
    alias rm="trash"
fi

if command -v rg &> /dev/null; then
    alias grep="rg"
fi

if command -v exa &> /dev/null; then
    alias ls="exa --classify \
                  --group-directories-first"

    alias ll="exa --classify \
                  --group-directories-first \
                  --almost-all \
                  --long \
                  --git \
                  --header \
                  --no-filesize \
                  --no-permissions \
                  --time-style='+%y-%m-%d %H:%M' \
                  --no-user" 
fi

alias clear="clear; __bash_empty_prompt="""
alias avt="auto-venv-toggle"
alias vu="venv-update"
alias va="venv-activate"
alias vd="venv-deactivate"


# == Prompt ==
function __precmd_func {
    # empty line between prompts
    if [[ -z "$__bash_empty_prompt" ]]; then
        __bash_empty_prompt="1"
    else
        echo ""
    fi

    # window title
    echo -ne "\e]0;${PWD/$HOME/\~}\a"

    # auto-venv
    if [[ -z "$__auto_venv_stop" ]]; then
        venv-update
    fi
}

starship_precmd_user_func="__precmd_func"


# == Init and env ==
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
    function cd {
        __zoxide_z "$@"
        ls -A
    }
else 
    function cd {
        command cd "$@"
        ls -A
    }
fi

if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

if command -v fzf &> /dev/null; then
    eval "$(fzf --bash)"
fi

if command -v hx &> /dev/null; then
    export VISUAL="hx"
    export EDITOR="hx"
fi

export FZF_DEFAULT_OPTS="--ansi --layout=reverse --height 10 \
                         --border=sharp"
export RUSTUP_HOME="$HOME"/.rustup
export CARGO_HOME="$HOME"/.cargo
export PAGER="less"
export LESS="--tilde -RFXS"
export RIPGREP_CONFIG_PATH="$HOME"/.config/ripgrep/config
