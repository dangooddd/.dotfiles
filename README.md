# **dangooddd's** linux dotfiles

> Set of configs for cli tools, terminal, shell and other stuff (Fedora).

## Installation

> [!Warning]
> Move existing files and directories manually, script will not touch them.

Clone repository:

```sh
git clone https://github.com/dangooddd/.dotfiles.git "$HOME"/.dotfiles
```

Link configuration files via script:

```sh
cd "$HOME"/.dotfiles
./install.sh
```

## Packages

Install fedora packages:

```sh
./scripts/fedora/install-fedora-packages.sh
```

Install arch packages:

```sh
./scripts/arch/install-arch-packages.sh
```

Install flatpak packages:

```sh
./scripts/install-flatpak-packages.sh
```
