################################################################################
# Common
################################################################################
shopt -s dotglob
shopt -s histappend
set -o emacs

if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x ${HOME}/.linuxbrew/bin/brew ]]; then
    eval "$("${HOME}/.linuxbrew/bin/brew" shellenv)"
fi

HISTSIZE=10000
HISTFILESIZE=10000
HISTCONTROL=ignoreboth:erasedups

if [[ -n $HOMEBREW_PREFIX ]]; then
    PATH="${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin:${PATH}"
fi

PATH="${PATH}:${HOME}/.local/bin:${HOME}/.cargo/bin"
export PATH

export FZF_DEFAULT_OPTS="
	--color=fg:#908caa,bg:#191724,hl:#ebbcba
	--color=fg+:#e0def4,bg+:#403d52,hl+:#ebbcba
	--color=border:#6e6a86,header:#31748f,gutter:#191724
	--color=spinner:#f6c177,info:#9ccfd8
	--color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa
    --layout=reverse --height=15 --border=sharp --ansi"

export LESS="--tilde -RFXS"
export PYTHONSTARTUP="${HOME}/.pythonstartup.py"
export CARGO_HOME="${HOME}/.cargo"
export PAGER="less"
export EDITOR="nvim"
export VIRTUAL_ENV_DISABLE_PROMPT=1

export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"


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

function v {
    local venv="${1:-.venv}"
    local dir="$PWD"

    while true; do
        local target="$dir/$venv"
        local activate="$target/bin/activate"

        if [[ -r "$activate" ]]; then
            if [[ -n $VIRTUAL_ENV && "$VIRTUAL_ENV" == "$target" ]]; then
                return
            fi

            if declare -F deactivate &> /dev/null; then
                deactivate
            fi

            source "$activate"
            return
        fi

        if [[ "$dir" == "/" ]]; then
            return 1
        fi

        dir="$(dirname "$dir")"
    done
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
if [[ -r ${HOME}/.bashrc.local ]]; then
    source "${HOME}/.bashrc.local"
fi

if [[ -r ${CARGO_HOME}/env ]]; then
    source "${CARGO_HOME}/env"
fi

if [[ -r /usr/share/git/completion/git-prompt.sh ]]; then
    source /usr/share/git/completion/git-prompt.sh
elif [[ -r /usr/lib/git-core/git-sh-prompt ]]; then
    source /usr/lib/git-core/git-sh-prompt
elif [[ -r ${HOMEBREW_PREFIX}/etc/bash_completion.d/git-completion.bash ]]; then
    source "${HOMEBREW_PREFIX}/etc/bash_completion.d/git-completion.bash"
fi

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion 
elif [[ -r /etc/bash_completion ]]; then
    source /etc/bash_completion
elif [[ -r ${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh ]]; then
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
fi


################################################################################
# Prompt
################################################################################
c_reset='\[\e[0m\]'
c_pwd='\[\e[32m\]'
c_ok='\[\e[36m\]'
c_fail='\[\e[31m\]'
c_info='\[\e[35m\]'

function __ps1_hook {
    local exit_code=$?

    PS1="${c_pwd}\w${c_reset}"

    if [[ -n $VIRTUAL_ENV ]]; then
        local venv_info="$(basename "$VIRTUAL_ENV")"
        [[ -n $venv_info ]] && PS1+=" ${c_info}(${venv_info})${c_reset}"
    fi

    if declare -F __git_ps1 &> /dev/null; then
        local git_info="$(__git_ps1 "%s")"
        [[ -n $git_info ]] && PS1+=" ${c_info}(${git_info})${c_reset}"
    fi

    local c_sign="$c_ok"
    (( exit_code != 0 )) && c_sign="$c_fail"
    PS1+=" ${c_sign}\$${c_reset} "
}

PROMPT_COMMAND="__ps1_hook;${PROMPT_COMMAND}"
