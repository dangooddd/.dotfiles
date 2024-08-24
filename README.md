# `dangooddd`'s linux dotfiles
> Set of configs for cli tools, terminal, shell and other stuff (Fedora).


## Configurations 
* **Terminal:** [WezTerm](https://github.com/wez/wezterm)
* **Prompt:** [Starship](https://github.com/starship/starship)
* **Shell:** [Bash](https://www.gnu.org/software/bash/)
* **TUI file manager:** [Yazi](https://github.com/sxyazi/yazi)
* **Code Editor:** [Helix](https://github.com/helix-editor/helix)
* **Font:** [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono)


## Installation

> [!Warning]
> Method below may be dangerous! 
> Existed configurations will be moved to $HOME/.local/share/Trash
> via trash-cli package

Installation script dependencies:
```sh
sudo dnf install bash trash-cli git
```

Clone repository:
```sh
git clone https://github.com/dangooddd/.dotfiles.git
```

Link configuration files via script:
```sh
cd .dotfiles
./install.sh
```


## Packages

Enable required copr repositories:
```sh 
sudo dnf copr enable wezfurlong/wezterm-nightly
```

Then install packages:
```sh
sudo dnf install cmake just python pip rustup \
    p7zip ImageMagick jq wl-clipboard fd-find \
    ripgrep poppler zoxide helix wezterm fzf  \
    jetbrains-mono-fonts-all 
```

Setup rust toolchain:
```sh
rustup-init
```

After that, install cargo packages:
```sh
cargo install --locked starship
cargo install --locked --git https://github.com/sxyazi/yazi.git yazi-fm yazi-cli
```

Then install yazi plugins:
```sh
ya pack -a yazi-rs/plugins#full-border
ya pack -a dangooddd/kanagawa
```


## Helix lsp
Check setup [guide](LSP.md) for my helix lsp config
