# `dangooddd`'s linux dotfiles
> Set of configs for cli tools, terminal, shell and other stuff (Fedora).


## Configurations 
* **Terminal:** [foot](https://codeberg.org/dnkl/foot)
* **Prompt:** Custom bash prompt
* **Shell:** [bash](https://www.gnu.org/software/bash/)
* **Code Editor:** [Helix](https://github.com/helix-editor/helix)
* **Font:** [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono)


## Installation

> [!Warning]
> Move existing file manually, script will not touch them.

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

Install packages via dnf:
```sh
sudo dnf install cmake just python pip \
    p7zip wl-clipboard fd-find fzf jq \
    helix foot tmux zoxide ripgrep \
    jetbrains-mono-fonts-all 
```


## Helix lsp
Check setup [guide](LSP.md) for my helix lsp config
