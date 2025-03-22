# `dangooddd`'s linux dotfiles

> Set of configs for cli tools, terminal, shell and other stuff (Fedora).

## Configurations 

* **Terminal:** [kitty](https://github.com/kovidgoyal/kitty)
* **Prompt:** [starship](https://github.com/starship/starship)
* **Shell:** [bash](https://www.gnu.org/software/bash/)
* **Code Editor:** [neovim](https://github.com/neovim/neovim)
* **Font:** [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono)
* **File manager:** [yazi](https://github.com/sxyazi/yazi)

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

Enable copr repositories:

```sh
sudo dnf copr enable -y atim/lazygit
```

Add vscode repository:

```sh
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
```

Install rpm packages:

```sh
sudo dnf install $(cat rpm.txt)
```

Install flatpak packages:

```sh
flatpak install $(cat flatpak.txt)
```

Install rust programming language:

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Install rust packages:

```sh
cargo install --locked starship
cargo install --locked yazi-fm yazi-cli
```

Install yazi plugins:

```sh
ya pack -u
```
