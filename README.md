# **dangooddd's** linux dotfiles

> Set of configs for cli tools, terminal, shell and other stuff (Fedora).

## Configurations 

- **Terminal:** [ghostty](https://github.com/ghostty-org/ghostty)
- **Prompt:** [starship](https://github.com/starship/starship)
- **Shell:** [bash](https://www.gnu.org/software/bash/)
- **TUI Editor:** [neovim](https://github.com/neovim/neovim)
- **GUI Editor:** [vscode](https://github.com/microsoft/vscode)
- **Font:** [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono)

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

Install rpm packages:

```sh
sudo dnf install $(cat rpm.txt) --skip-unavailable
```

Install flatpak packages:

```sh
flatpak install $(cat flatpak.txt)
```
