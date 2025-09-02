################################################################################
# General
################################################################################
setopt globdots
setopt histignoredups
setopt sharehistory
setopt histexpiredupsfirst
setopt autocd

bindkey -e
bindkey "$terminfo[kRIT5]" forward-word # ctrl+right
bindkey "$terminfo[kLFT5]" backward-word # ctrl+left
bindkey "$terminfo[kcbt]" reverse-menu-complete # shift+tab
bindkey "^H" backward-kill-word # ctrl+backspace
bindkey "^[[3;5~" kill-word # ctrl+delete

if command -v dircolors &> /dev/null; then
    eval "$(dircolors -b)"
fi

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

path+=("$HOME"/.local/bin)
path+=("$HOME"/.cargo/bin)
export PATH

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

export LESS="--tilde -RFXS"
export PYTHONSTARTUP="$HOME"/.pythonstartup.py
export CARGO_HOME="$HOME"/.cargo
export PAGER="less"


################################################################################
# Completions
################################################################################
zmodload zsh/complist
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" "ma=38;5;7;7"
zstyle ':completion:*' group-name ""
zstyle ':completion:*:*:*:*:descriptions' format "%F{8}> %d%f"


################################################################################
# Aliases and functions
################################################################################
function venv-autoupdate-toggle {
    if [[ -z $__venv_autoupdate_stop ]]; then
        __venv_autoupdate_stop="Y"
    else
        __venv_autoupdate_stop=""
    fi
}

function venv-update-setname {
    __venv_update_name="$1"
    if [[ -z $__venv_update_name ]]; then
        __venv_update_name=".venv"
    fi

    if [[ -n $VIRTUAL_ENV ]]; then
        deactivate
    fi
}

__venv_update_name=.venv
function venv-update {
    local activate="$__venv_update_name/bin/activate"
    [[ -e $activate ]] || activate=""

    # not active
    if [[ -z $VIRTUAL_ENV ]] &&
        [[ -n $activate ]]; then
        source "$activate"
    fi

    # nested interactive shells
    if [[ -n $VIRTUAL_ENV ]] &&
        [[ $(type -w deactivate) != *function* ]]; then
        source "$VIRTUAL_ENV"/bin/activate
    fi

    # update venv
    if [[ -n $VIRTUAL_ENV ]] &&
        [[ -n $activate ]] &&
        [[ $VIRTUAL_ENV/bin/activate != $PWD/$activate ]]; then
        source "$activate"
    fi

    # exit of venv
    if [[ -n $VIRTUAL_ENV ]] &&
        ! [[ $PWD =~ $(dirname "$VIRTUAL_ENV") ]]; then
        deactivate
    fi
}

function ls {
    command ls --group-directories-first \
               --color=auto "$@"
}

function la {
    ls -Av "$@"
}

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
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

if command -v fzf &> /dev/null; then
    eval "$(fzf --zsh)"
fi

if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi


################################################################################
# Hooks
################################################################################
autoload -Uz add-zsh-hook

function set-title {
    echo -ne "\e]0;${PWD/#$HOME/~}\a"
}
set-title

function osc7-pwd() {
    (( ZSH_SUBSHELL )) && return
    emulate -L zsh
    setopt extendedglob
    local LC_ALL=C
    printf '\e]7;file://%s%s\e\' "$HOST" "${PWD//(#m)([^@-Za-z&-;_~])/%${(l:2::0:)$(([##16]#MATCH))}}"
}
osc7-pwd

function venv-autoupdate {
    if [[ -z "$__venv_autoupdate_stop" ]]; then
        venv-update
    fi
}
venv-autoupdate

add-zsh-hook chpwd set-title 
add-zsh-hook chpwd osc7-pwd
add-zsh-hook chpwd venv-autoupdate
add-zsh-hook chpwd la


################################################################################
# Sourcing
################################################################################
function include {
    if [[ $# -eq 0 ]]; then
        return 1
    fi

    local file="$1"
    shift 1

    if [[ -f $file && -r $file ]]; then
        source "$file" "$@"
        return $?
    fi

    return 1
}

include "$CARGO_HOME"/env
include /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
