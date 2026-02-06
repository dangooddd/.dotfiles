################################################################################
# General
################################################################################
setopt globdots
setopt histignoredups
setopt sharehistory
setopt histexpiredupsfirst
setopt promptsubst
setopt autocd

bindkey -e
bindkey "^[[1;5C" forward-word # ctrl+right
bindkey "^[[1;5D" backward-word # ctrl+left
bindkey "^[[Z" reverse-menu-complete # shift+tab
bindkey "^H" backward-kill-word # ctrl+backspace
bindkey "^[[3;5~" kill-word # ctrl+delete

if command -v dircolors &> /dev/null; then
    eval "$(dircolors -b)"
fi

for brew_path in \
    "/opt/homebrew/bin/brew" \
    "/home/linuxbrew/.linuxbrew/bin/brew" \
    "$HOME/.linuxbrew/bin/brew"
do
if [ -x "$brew_path" ]; then
    eval "$("$brew_path" shellenv)"
    break
fi
done

HISTFILE="$HOME"/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Use bold colors, so in tty it becomes bright
[[ -z $DISPLAY ]] && ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=black,bold" 

if command -v brew &> /dev/null; then
    path=("$(brew --prefix)"/opt/coreutils/libexec/gnubin $path)
    fpath=("$(brew --prefix)"/share/zsh-completions $fpath)
    fpath=("$(brew --prefix)"/share/zsh/site-functions $fpath)
fi

path+=("$HOME"/.local/bin)
path+=("$HOME"/.cargo/bin)
export PATH
export FPATH

FZF_COLORS+=",fg:-1"
FZF_COLORS+=",bg:-1"
FZF_COLORS+=",hl:-1:dim"
FZF_COLORS+=",fg+:-1"
FZF_COLORS+=",bg+:#444444"
FZF_COLORS+=",hl+:10"
FZF_COLORS+=",info:8"
FZF_COLORS+=",prompt:12"
FZF_COLORS+=",pointer:12"
FZF_COLORS+=",marker:2"
FZF_COLORS+=",spinner:6"
FZF_COLORS+=",header:8"
FZF_COLORS+=",border:8"

export FZF_DEFAULT_OPTS="--layout=reverse \
                         --height 10 \
                         --ansi \
                         --border=sharp \
                         --no-bold \
                         --color=$FZF_COLORS"

export LESS="--tilde -RFXS"
export PYTHONSTARTUP="$HOME"/.pythonstartup.py
export CARGO_HOME="$HOME"/.cargo
export PAGER="less"
export EDITOR="nvim"
export VIRTUAL_ENV_DISABLE_PROMPT=1

export XDG_CONFIG_HOME="$HOME"/.config
export XDG_CACHE_HOME="$HOME"/.cache
export XDG_DATA_HOME="$HOME"/.local/share
export XDG_STATE_HOME="$HOME"/.local/state


################################################################################
# Prompt
################################################################################
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '[%b]'
zstyle ':vcs_info:git:*' actionformats '[%b|%a]'

function virtualenv_info {
    if [[ -n $VIRTUAL_ENV ]]; then
        local venv_name="${VIRTUAL_ENV##*/}"
        local python_version=$(python --version 2>&1 | cut -d' ' -f2)
        echo "[$venv_name|v$python_version]"
    fi
}

function git_info {
    vcs_info
    echo "$vcs_info_msg_0_"
}

PROMPT='%F{2}%~%f '
PROMPT+='%(?.%F{6}.%F{1})%%%f '

RPROMPT='%F{3}$(virtualenv_info)%f'
RPROMPT+='%(1j.%F{4}[jobs|+%j].)%f'
RPROMPT+='%F{5}$(git_info)%f'


################################################################################
# Completions
################################################################################
zmodload zsh/complist
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"


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
        return
    fi

    # nested interactive shells
    if [[ -n $VIRTUAL_ENV ]] &&
        [[ $(type -w deactivate) != *function* ]]; then
        source "$VIRTUAL_ENV"/bin/activate
        return
    fi

    # update venv
    if [[ -n $VIRTUAL_ENV ]] &&
        [[ -n $activate ]] &&
        [[ $VIRTUAL_ENV/bin/activate != $PWD/$activate ]]; then
        source "$activate"
        return
    fi

    # exit of venv
    if [[ -n $VIRTUAL_ENV ]] &&
        ! [[ $PWD =~ $(dirname "$VIRTUAL_ENV") ]]; then
        deactivate
        return
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
if command -v fzf &> /dev/null; then
    eval "$(fzf --zsh)"
fi

if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" &> /dev/null
fi


################################################################################
# Hooks
################################################################################
autoload -Uz add-zsh-hook

function set-title {
    echo -ne "\e]0;${PWD/#$HOME/~}\a"
}
set-title

function venv-autoupdate {
    if [[ -z "$__venv_autoupdate_stop" ]]; then
        venv-update
    fi
}
venv-autoupdate

add-zsh-hook chpwd set-title 
add-zsh-hook chpwd venv-autoupdate
add-zsh-hook chpwd la


################################################################################
# Sourcing
################################################################################
function include {
    if [[ $# -eq 0 ]]; then
        return
    fi

    local file="$1"
    shift 1

    if [[ -f $file && -r $file ]]; then
        source "$file" "$@"
    fi
}

include "$HOME"/.zshrc.local
include "$CARGO_HOME"/env
include /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

if command -v brew &> /dev/null; then
    include "$(brew --prefix)"/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
