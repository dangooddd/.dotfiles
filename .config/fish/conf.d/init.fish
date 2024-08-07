# init fish

# no new line if var unset (on start of terminal)
# new line if var is set
function prompt_newline --on-event fish_prompt
    if test -z $__fish_empty_prompt
        set -g __fish_empty_prompt 1
    else
        echo
    end
end


# init cli tools
if command -vq zoxide
    zoxide init fish | source
end

if command -vq starship
    starship init fish | source
end
