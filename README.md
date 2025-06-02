# **dangooddd's** linux dotfiles

> Set of configs for cli tools, terminal, shell and other stuff (Fedora).

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
sudo dnf install $(cat packages/rpm.txt) --skip-unavailable
```

Install flatpak packages:

```sh
flatpak install $(cat packages/flatpak.txt)
```
