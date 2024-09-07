# `dangooddd`'s linux dotfiles
> Set of configs for cli tools, terminal, shell and other stuff (Fedora).


## Configurations 
* **Terminal:** [foot](https://codeberg.org/dnkl/foot)
* **Prompt:** Custom bash prompt
* **Shell:** [bash](https://www.gnu.org/software/bash/)
* **Code Editor:** [neovim](https://github.com/neovim/neovim)
* **Font:** [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono)


## Installation

> [!Warning]
> Move existing files and directories manually, script will not touch them.

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
    wl-clipboard fd-find fzf jq ripgrep \
    neovim foot tmux zoxide \
    jetbrains-mono-fonts-all 
```
