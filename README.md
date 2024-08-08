# `dangooddd`'s linux dotfiles
> Set of cli tools, terminal and shell configs for personal usage.
> Also contains install script for fast install and setup 
of required packages. 

## Configurations 
* **Terminal:** [WezTerm](https://github.com/wez/wezterm)
* **Prompt:** [Starship](https://github.com/starship/starship)
* **Shell:** [Fish](https://github.com/fish-shell/fish-shell)
* **TUI file manager:** [Yazi](https://github.com/sxyazi/yazi)
* **Code Editor:** [Helix](https://github.com/helix-editor/helix)
* **Font:** [Inter](https://github.com/rsms/inter) as UI font and [Cascadia Code](https://github.com/microsoft/cascadia-code) as monospace font

## Packages
### Fedora
Enable some copr repos:
```bash 
sudo dnf copr enable -y che/nerd-fonts
sudo dnf copr enable -y wezfurlong/wezterm-nightly
```
Then install packages:
```bash
sudo dnf install -y cmake fish cascadia-code-fonts cascadia-code-pl-fonts \
    rsms-inter-fonts nerd-fonts p7zip ImageMagick jq wl-clipboard fd-find \
    ripgrep fzf poppler wezterm zoxide cargo helix just
```
Then install language-dependent packages:
```bash
cargo install --locked starship
cargo install --locked --git https://github.com/sxyazi/yazi.git yazi-fm yazi-cli
```
Then install yazi plugins:
```bash
ya pack -a yazi-rs/plugins#full-border
ya pack -a dangooddd/kanagawa
```
Change shell to zsh:
```bash
fish -c "fish_config theme save Kanagawa"
chsh -s $(which zsh)
```

## Installation

### Download
```bash
git clone https://github.com/dangooddd/.dotfiles.git
```

### Manual
Copy or symlink all directories you want

### Via script
> [!Warning]
> Method below may be dangerous! Some files from your filesystem can be deleted, so read code and make your decision!

Script will link dotfiles to your filesystem 
(existing directories will be moved in /path/to/dotfiles/.backup)
and install all required packages (Fedora only!):
```bash
cd .dotfiles
./install.sh
```
To only link all configurations (without installing of packages):
```bash
./install.sh link
```
