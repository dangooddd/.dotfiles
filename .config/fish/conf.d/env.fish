# fish env variables

# to avoid some shit
if command -vq hx
    set -x VISUAL hx
    set -x EDITOR hx
end

set -x PAGER less
set -x LESS "--tilde -RFXS"
set -x RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/config"
