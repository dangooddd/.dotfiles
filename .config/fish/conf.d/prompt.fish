# handle of fish_prompt event

# no new line if var unset (on start of terminal)
# new line if var is set
function prompt_newline --on-event fish_prompt
    if test -z $__fish_empty_prompt
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
    if test -z $VIRTUAL_ENV
        if test -e $venv
            source $venv
            set -g __auto_venv_path $PWD
        end
    else
        if test (dirname $__auto_venv_path) -ef $PWD
            set -g __auto_venv_path ""
            deactivate
        end
    end
end
