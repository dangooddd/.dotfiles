# `dangooddd`'s linux dotfiles

> Set of configs for cli tools, terminal, shell and other stuff (Fedora).


## Configurations 

* **Terminal:** [kitty](https://github.com/kovidgoyal/kitty)
* **Prompt:** [starship](https://github.com/starship/starship)
* **Shell:** [bash](https://www.gnu.org/software/bash/)
* **Code Editor:** [neovim](https://github.com/neovim/neovim)
* **Font:** [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono)
* **File manager:** [yazi](https://github.com/sxyazi/yazi)
* **Fetch:** [fastfetch](https://github.com/fastfetch-cli/fastfetch)


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

Install rust programming language:
```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Install rust packages:
```sh
cargo install starship --locked
cargo install --locked yazi-fm yazi-cli
```

Install yazi plugins:
```sh
ya pack -u
```
