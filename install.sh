#!/usr/bin/env bash

# colored output
function colored {
    local color
    local end
    case "$1" in
        "red") color="\e[0;31m";;
        "green") color="\e[0;32m";;
        "magenta") color="\e[0;35m";;
        "yellow") color="\e[1;33m";;
    esac
    end="\e[0m"
    printf "$color$2$end"
}

# directory remove
# if directory is link, delete link file
# (linked directory will be fine)
function ddir {
    if [ -d "$1" ]; then
        if [ -L "$1" ]; then
            rm "$1"
        else
            rm -rf "$1"
        fi
        colored "red" "# "
        printf "Remove %s\n" "$1"
    fi
}

# directory installation with backup if already exist
function dinstall {
    # $1 - src, $2 - dst, $3 - back

    if [ -d "$2" ]; then
        if [ -d "$3" ]; then
            ddir "$3"
        fi
        mv "$2" "$3"
        colored "yellow" "* "
        printf "Move %s to %s\n" "$2" "$3"
    fi

    colored "green" "+ "
    printf "Link %s to %s\n\n" "$1" "$2"
    ln -s "$1" "$2"
}

# file installation with backup if already exist
function finstall {
    # $1 - src, $2 - dst, $3 - back
    if [ -f "$2" ] || [ -L "$2" ]; then
        if [ -f "$3" ] || [ -L "$3" ]; then
            rm "$3"
            colored "red" "# "
            printf "Remove %s\n" "$3"
        fi
        mv "$2" "$3"
        colored "yellow" "* "
        printf "Move %s to %s\n" "$2" "$3"
    fi

    colored "green" "+ "
    printf "Link %s to %s\n\n" "$1" "$2"
    ln -s "$1" "$2"
}

# installation of config files
function installConfigs {
    colored "magenta" "\n[ "
    colored "red" "Installing dangooddd dotfiles"
    colored "magenta" " ]\n\n"

    local dotfiles
    dotfiles="$(dirname "$(readlink -f "$0")")"
    mkdir -p "$dotfiles"/.backup/.config
    shopt -s dotglob

    for src in "$dotfiles"/.config/*
    do
        local name
        name="$(basename "$src")"

        if [ -d "$src" ]; then
            dinstall "$src" \
                     "$HOME"/.config/"$name" \
                     "$dotfiles"/.backup/.config/"$name"
        fi

        if [ -f "$src" ] || [ -L "$src" ]; then
            finstall "$src" \
                     "$HOME"/.config/"$name" \
                     "$dotfiles"/.backup/.config/"$name"
        fi
    done

    for src in "$dotfiles"/.home/*
    do
        local name
        name="$(basename "$src")"

        if [ -d "$src" ]; then
            dinstall "$src" \
                     "$HOME"/"$name" \
                     "$dotfiles"/.backup/"$name"
        fi

        if [ -f "$src" ] || [ -L "$src" ]; then
            finstall "$src" \
                     "$HOME"/"$name" \
                     "$dotfiles"/.backup/"$name"
        fi
    done

    dinstall "$dotfiles"/.wallpapers \
             "$HOME"/.wallpapers \
             "$dotfiles"/.backup/.wallpapers

    colored "magenta" "[ "
    colored "red" "Dotfiles installed!"
    colored "magenta" " ]\n"
}

# installation of required packages
function installPackages {
    colored "magenta" "\n[ "
    colored "red" "Installing packages for dangooddd dotfiles"
    colored "magenta" " ]\n\n"

    sudo dnf copr enable -y che/nerd-fonts
    sudo dnf copr enable -y wezfurlong/wezterm-nightly
    
    sudo dnf install -y cmake fish cascadia-code-fonts cascadia-code-pl-fonts \
        rsms-inter-fonts nerd-fonts p7zip ImageMagick jq wl-clipboard fd-find \
        ripgrep fzf poppler wezterm zoxide cargo helix just

    cargo install --locked starship
    cargo install --locked --git https://github.com/sxyazi/yazi.git yazi-fm yazi-cli
    "$HOME"/.cargo/bin/ya pack -a yazi-rs/plugins#full-border

    fish -c "fish_config theme save Kanagawa"
    chsh -s $(which fish)

    colored "magenta" "\n[ "
    colored "red" "Packages installed!"
    colored "magenta" " ]\n"
}

# install
case "$1" in
    # only link
    "link")
        installConfigs
        ;;
    # full installation
    *)
        installConfigs
        installPackages
        ;;
esac
