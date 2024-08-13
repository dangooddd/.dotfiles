# `dangooddd`'s linux dotfiles
> Set of configs for cli tools, terminal, shell and other stuff.


## Configurations 
* **Terminal:** [WezTerm](https://github.com/wez/wezterm)
* **Prompt:** [Starship](https://github.com/starship/starship)
* **Shell:** [Fish](https://github.com/fish-shell/fish-shell)
* **TUI file manager:** [Yazi](https://github.com/sxyazi/yazi)
* **Code Editor:** [Helix](https://github.com/helix-editor/helix)
* **Font:** [Cascadia Code](https://github.com/microsoft/cascadia-code)


## Installation

```bash
git clone https://github.com/dangooddd/.dotfiles.git
```

### Via script
> [!Warning]
> Method below may be dangerous! Some files from your filesystem can be deleted, so read code and make your decision!

Script will install dotfiles for current user 
(existing directories will be moved in /path/to/dotfiles/.backup):
```bash
cd .dotfiles
./install.sh
```


## Packages

### Fedora Linux

Enable required copr repositories:
```sh 
sudo dnf copr enable wezfurlong/wezterm-nightly
```

Then install packages:
```sh
sudo dnf install cascadia-code-pl-fonts google-roboto-fonts \
    cmake fish p7zip ImageMagick jq wl-clipboard fd-find \
    ripgrep fzf poppler wezterm zoxide rustup helix just
```

Setup rust toolchain:
```sh
export CARGO_HOME="$HOME"/.cargo
export RUSTUP_HOME="$HOME"/.rustup
rustup-init
```

Change shell to fish:
```sh
fish -c "fish_config theme save Kanagawa"
chsh -s $(which fish); fish
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
