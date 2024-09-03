# .bashrc

#======================================
# Prompt
#======================================
function __precmd_hook {
    # exit code
    __exit_code=$?

    # empty line between prompts
    if [[ -z "$__bash_empty_prompt" ]]; then
        __bash_empty_prompt="Y"
    else
        echo ""
    fi

    # window title
    echo -ne "\e]0;${PWD/#$HOME/\~}\a"

    # auto-venv
    if [[ -z "$__auto_venv_stop" ]]; then
        venv-update
    fi
}

function __pwd_prompt_module {
    echo " $(basename ${PWD/#$HOME/\~}) "
}

function __status_prompt_module {
    local status=""
    if ! [[ -z "$VIRTUAL_ENV" ]]; then
        status+=" v"
    fi

    if command git rev-parse &> /dev/null; then
        status+=" g"
    fi

    if ! [[ -z "$status" ]]; then
        status+=" "
    fi

    echo "$status"
}

function __char_prompt_module {
    if [[ $__exit_code -eq 0 ]]; then
        echo ' $ '
    else
        echo ' # '
    fi
}

VIRTUAL_ENV_DISABLE_PROMPT="Y"
PROMPT_COMMAND=("__precmd_hook" "${PROMPT_COMMAND[@]}")
PS1='\[\e[0m\]\
\[\e[48;2;230;195;132m\]\[\e[38;2;31;31;40m\]$(__pwd_prompt_module)\[\e[0m\]\
\[\e[48;2;54;54;70m\]\[\e[38;2;230;195;132m\]\[\e[0m\]\
\[\e[48;2;54;54;70m\]\[\e[38;2;184;180;208m\]$(__status_prompt_module)\[\e[0m\]\
\[\e[48;2;184;180;208m\]\[\e[38;2;54;54;70m\]\[\e[0m\]\
\[\e[48;2;184;180;208m\]\[\e[38;2;31;31;40m\]$(__char_prompt_module)\[\e[0m\]\
\[\e[38;2;184;180;208m\]\[\e[0m\] '


#======================================
# Global definitions
#======================================
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi


#======================================
# Path 
#======================================
function addPath {
    if ! [[ "$PATH" =~ "$1:" ]]; then
        PATH="$1:$PATH"
        export PATH
    fi
}
addPath "$HOME/.local/bin"
addPath "$HOME/.cargo/bin"


#======================================
# Bash options
#======================================
export HISTSIZE=500
export HISTFILESIZE=10000
export HISTTIMEFORMAT="%F %T "
export HISTCONTROL="erasedups:ignoreboth"
shopt -s histappend
shopt -s checkwinsize


#======================================
# Aliases and functions
#======================================
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
        ! [[ "$(type -t deactivate)" == "function" ]]; then
        . "$VIRTUAL_ENV"/bin/activate
    fi

    if ! [[ -z "$VIRTUAL_ENV" ]] &&
        [[ "$(dirname "$VIRTUAL_ENV")" != "$PWD" ]] &&
        [[ -e "$venv" ]]; then
        . "$venv"
    fi

    if ! [[ -z "$VIRTUAL_ENV" ]] &&
        ! [[ "$PWD" =~ "$(dirname "$VIRTUAL_ENV")" ]]; then
        deactivate
    fi
}

function ls {
    command ls --group-directories-first \
               --color=auto "$@"
}

function clear {
    command clear
    __bash_empty_prompt=""
}

function yank {
    for val in "$@"
    do 
        if [[ "$val" == "-c" ]]; then
            __yank_source=()
            return 0
        fi

        if [[ "$val" == "-l" ]]; then
            for each in "${__yank_source[@]}"
            do
                echo "$each"
            done
            return 0
        fi

        local realval="$(readlink -f "$val")"
        if [[ -e "$realval" ]]; then
            __yank_source+=("$realval")
        fi
    done
}

function paste {
    for opt in "$@"
    do
        if [[ "$opt" == "-q" ]]; then
            local quiet="Y"
        fi

        if [[ "$opt" == "-x" ]]; then
            local insert="Y"
        fi
    done

    for src in "${__yank_source[@]}"
    do
        if ! [[ -z "$insert" ]]; then
            mv -i "$src" ./
        else
            cp -ir "$src" ./
        fi
    done
    __yank_source=()

    if [[ -z "$quiet" ]]; then
        ls -Av
    fi
}

alias la="ls -Av"

alias ll="ls -Alv"

alias rg="rg --smart-case \
             --hidden \
             --glob=!./git \
             --pretty"

alias c="clear"


#======================================
# Init and env
#======================================
if command -v hx &> /dev/null; then
    export VISUAL="hx"
    export EDITOR="hx"
fi

export FZF_DEFAULT_OPTS="--layout=reverse \
                         --height 10 \
                         --ansi \
                         --border=sharp"

export RUSTUP_HOME="$HOME"/.rustup
export CARGO_HOME="$HOME"/.cargo
export PAGER="less"
export LESS="--tilde -RFXS"

if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
    function zd {
        __zoxide_z "$@" && ls -Av
    }
fi

if command -v fzf &> /dev/null; then
    eval "$(fzf --bash)"
fi
