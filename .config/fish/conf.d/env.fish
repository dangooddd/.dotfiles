# fish env variables

# helix
if command -vq hx
    set -x VISUAL hx
    set -x EDITOR hx
end

# rustup
if test -z $RUSTUP_HOME
    set -x RUSTUP_HOME "$HOME/.rustup"
end

# cargo
if test -z $CARGO_HOME
    set -x CARGO_HOME "$HOME/.cargo"
end

set -x PAGER less
set -x LESS "--tilde -RFXS"
set -x RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/config"
