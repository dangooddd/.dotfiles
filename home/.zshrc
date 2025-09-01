################################################################################
# General
################################################################################
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
bindkey -e

setopt GLOB_DOTS
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST

if command -v dircolors &> /dev/null; then
    eval "$(dircolors -b)"
fi

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
export DIRENV_BASH=$(which bash)

include "$CARGO_HOME"/env
include /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# include /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


################################################################################
# Completions
################################################################################
zmodload zsh/complist
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" "ma=38;5;13;7"
zstyle ':completion:*:*:*:*:descriptions' format '%F{13}-- %d --%f'
zstyle ':completion:*' group-name ''
bindkey '^[[Z' reverse-menu-complete


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
    printf '\e]7;file://%s%s\e\' $HOST ${PWD//(#m)([^@-Za-z&-;_~])/%${(l:2::0:)$(([##16]#MATCH))}}
}

function venv-autoupdate {
    if [[ -z "$__venv_autoupdate_stop" ]]; then
        venv-update
    fi
}

add-zsh-hook chpwd set-title 
add-zsh-hook chpwd osc7-pwd
add-zsh-hook chpwd venv-autoupdate
add-zsh-hook chpwd la


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
    local activate_tmp="$__venv_update_name/bin/activate"
    local activate=""
    [[ -e ../$activate_tmp ]] && activate=../"$activate_tmp"
    [[ -e $activate_tmp ]] && activate="$activate_tmp"

    # not active
    if [[ -z $VIRTUAL_ENV ]] &&
        [[ -n $activate ]]; then
        source "$activate"
    fi

    # nested interactive shells (for example, tmux)
    if [[ -n "$VIRTUAL_ENV" ]] &&
        [[ $(type -w deactivate) != *function* ]]; then
        source "$VIRTUAL_ENV"/bin/activate
    fi

    # update venv
    if [[ -n $VIRTUAL_ENV ]] &&
        [[ "$(dirname "$VIRTUAL_ENV")" != "$PWD" ]] &&
        [[ -n $activate ]]; then
        source "$activate"
    fi

    # exit of venv
    if [[ -n $VIRTUAL_ENV ]] &&
        ! [[ "$PWD" =~ "$(dirname "$VIRTUAL_ENV")" ]]; then
        deactivate
    fi
}

function ls {
    command ls --group-directories-first \
               --color=auto "$@"
}

function la {
    ls -Av
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
