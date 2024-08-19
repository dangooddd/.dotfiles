# handle of fish_prompt event

# no new line if var unset (on start of terminal)
# new line if var is set
function prompt_newline --on-event fish_prompt
    if [ -z "$__fish_empty_prompt" ]
        set -g __fish_empty_prompt 1
    else
        echo
    end
end

# activate venv on enter of directory
# deactivate venv on exit of directory
# ! only if venv name is ".venv" !
function auto_venv --on-event fish_prompt
    set -l venv ./.venv/bin/activate.fish

    if [ -n "$VIRTUAL_ENV" ]
        # check is $PWD contains (dirname "$VIRTUAL_ENV") (exit venv)
        # or new venv is available (enter new venv)
        if not string match -e -q (dirname "$VIRTUAL_ENV") "$PWD"
            or begin [ -e "$venv" ]; and not [ (dirname "$VIRTUAL_ENV") -ef "$PWD" ]; end
            deactivate
        end
    end

    if [ -z "$VIRTUAL_ENV" ]
        and [ -e "$venv" ]
        and [ -z "$__auto_venv_stop" ]
        source $venv
    end
end

function auto_venv_toggle
    if [ -z "$__auto_venv_stop" ]
        set -g __auto_venv_stop true
        echo "Stop auto_venv!"
    else
        set -e __auto_venv_stop
        echo "Continue auto_venv!"
    end
end
