# fish env variables

# to avoid some shit
if command -vq hx
    set -x EDITOR hx
end

set -x LESS "--tilde -RXS"
set -x RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/ripgrep.conf"
