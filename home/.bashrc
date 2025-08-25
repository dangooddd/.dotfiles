################################################################################
# General
################################################################################
if [[ -f /etc/bashrc ]]; then
    . /etc/bashrc
fi

if [[ -f "$HOME"/.bash_local ]]; then
    . "$HOME"/.bash_local
fi

function add-path {
    if ! [[ "$PATH" =~ "$1:" ]]; then
        PATH="$1:$PATH"
        export PATH
    fi
}
add-path "$HOME"/.local/bin
add-path "$HOME"/.cargo/bin

export HISTSIZE=1000
export HISTFILESIZE=10000
export HISTTIMEFORMAT="%F %T "
export HISTCONTROL="erasedups:ignoreboth"
shopt -s histappend
shopt -s checkwinsize

FZF_COLORS="gutter:#1d2021"
FZF_COLORS+=",fg:#ebdbb2"
FZF_COLORS+=",bg:#1d2021"
FZF_COLORS+=",hl:#928374"
FZF_COLORS+=",fg+:#ebdbb2"
FZF_COLORS+=",bg+:#3c3836"
FZF_COLORS+=",hl+:#d3869b"
FZF_COLORS+=",info:#665c54"
FZF_COLORS+=",prompt:#b8bb26"
FZF_COLORS+=",pointer:#fb4934"
FZF_COLORS+=",marker:#b16286"
FZF_COLORS+=",spinner:#83a598"
FZF_COLORS+=",header:#928374"
FZF_COLORS+=",border:#a89984"

export FZF_DEFAULT_OPTS="--layout=reverse \
                         --height 10 \
                         --ansi \
                         --border=rounded \
                         --highlight-line \
                         --no-bold \
                         --color=$FZF_COLORS"

export PYTHONSTARTUP="$HOME"/.pythonstartup.py
export RUSTUP_HOME="$HOME"/.rustup
export CARGO_HOME="$HOME"/.cargo
export PAGER="less"
export LESS="--tilde -RFXS"

if [[ -f "$CARGO_HOME"/env ]]; then
    . "$CARGO_HOME"/env
fi

if command -v nvim &> /dev/null; then
    export VISUAL="nvim"
    export EDITOR="nvim"
fi


################################################################################
# Prompt
################################################################################
function __venv_autoupdate {
    if [[ -z "$__venv_autoupdate_stop" ]]; then
        venv-update
    fi
}

function __window_title {
    echo -ne "\e]0;${PWD/#$HOME/\~}\a"
}

function __osc7_cwd {
    local strlen=${#PWD}
    local encoded=""
    local pos c o
    for (( pos=0; pos<strlen; pos++ )); do
        c=${PWD:$pos:1}
        case "$c" in
            [-/:_.!\'\(\)~[:alnum:]] ) o="${c}" ;;
            * ) printf -v o '%%%02X' "'${c}" ;;
        esac
        encoded+="${o}"
    done
    printf '\e]7;file://%s%s\e\\' "${HOSTNAME}" "${encoded}"
}

function __precmd_hook {
    __venv_autoupdate
    __window_title
    __osc7_cwd
}

if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
    starship_precmd_user_func="__precmd_hook"
    export VIRTUAL_ENV_DISABLE_PROMPT="Y"
else
    PROMPT_COMMAND+=("__precmd_hook")
    export VIRTUAL_ENV_DISABLE_PROMPT=""
fi


################################################################################
# Aliases and functions
################################################################################
function venv-autoupdate-toggle {
    if [[ -z "$__venv_autoupdate_stop" ]]; then
        __venv_autoupdate_stop="Y"
    else
        __venv_autoupdate_stop=""
    fi
}

function venv-update-setname {
    __venv_update_name="$1"
    if [[ -z "$__venv_update_name" ]]; then
        __venv_update_name=".venv"
    fi

    if [[ -n "$VIRTUAL_ENV" ]]; then
        deactivate
    fi
}

__venv_update_name=.venv
function venv-update {
    local path="$__venv_update_name/bin/activate"
    local venv=""
    [[ -e "../$path" ]] && venv="../$path"
    [[ -e "$path" ]] && venv="$path"

    # not active
    if [[ -z "$VIRTUAL_ENV" ]] &&
        [[ -n "$venv" ]]; then
        . "$venv"
    fi

    # nested interactive shells (for example, tmux)
    if [[ -n "$VIRTUAL_ENV" ]] &&
        ! [[ "$(type -t deactivate)" == "function" ]]; then
        . "$VIRTUAL_ENV"/bin/activate
    fi

    # update venv
    if [[ -n "$VIRTUAL_ENV" ]] &&
        [[ "$(dirname "$VIRTUAL_ENV")" != "$PWD" ]] &&
        [[ -n "$venv" ]]; then
        . "$venv"
    fi

    # exit of venv
    if [[ -n "$VIRTUAL_ENV" ]] &&
        ! [[ "$PWD" =~ "$(dirname "$VIRTUAL_ENV")" ]]; then
        deactivate
    fi
}

function ls {
    command ls --group-directories-first \
               --color=auto "$@"
}

function yank {
    for val in "$@"
    do 
        local realval
        realval="$(readlink -f "$val")"
        if [[ -e "$realval" ]]; then
            __yank_source+=("$realval")
        fi
    done
}

function yank-clear {
    __yank_source=()
}

function yank-list {
    for path in "${__yank_source[@]}"
    do
        echo "${path/#$HOME/\~}"
    done
}

function paste {
    for src in "${__yank_source[@]}"
    do
        cp -ir "$src" ./
    done
    __yank_source=()
    ls -Av
}

function paste-cut {
    for src in "${__yank_source[@]}"
    do
        mv -i "$src" ./
    done
    __yank_source=()
    ls -Av
}

alias la="ls -Av"
alias ll="ls -Alv"
alias rg="rg --smart-case \
             --hidden \
             --glob=!./git \
             --pretty"
alias gg="git status -s"
alias gb="git branch"
alias gl="git log"
alias ga="git add"
alias gc="git commit"
alias gp="git push"


################################################################################
# Init
################################################################################
if command -v fzf &> /dev/null; then
    eval "$(fzf --bash)"
fi

if command -v direnv &> /dev/null; then
    eval "$(direnv hook bash)"
fi

if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
    function zd {
        __zoxide_z "$@" && ls -Av
    }
fi
