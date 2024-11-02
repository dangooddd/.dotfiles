# `dangooddd`'s linux dotfiles

> Set of configs for cli tools, terminal, shell and other stuff (Fedora).


## Configurations 

* **Terminal:** [alacritty](https://github.com/alacritty/alacritty)
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
sudo dnf install $(cat packages.txt)
```
