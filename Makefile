stow_dir := stow
script_dir := script

.ONESHELL:
.SHELLFLAGS := -euo pipefail -c
.PHONY: stow unstow arch macos dev

stow:
	cd $(stow_dir)
	stow --no-folding -v -t ~ *

unstow:
	cd $(stow_dir)
	stow --no-folding -D -v -t ~ *

arch:
	cd $(script_dir)
	./install-yay.sh
	./install-arch-packages.sh
	./install-flatpak-packages.sh
	./install-uv-packages.sh

macos:
	cd $(script_dir)
	./install-brew.sh
	eval "$$(./get-brew-shellenv.sh)"
	./install-dev-packages.sh
	./install-uv-packages.sh

dev:
	cd $(script_dir)
	./install-brew.sh
	eval "$$(./get-brew-shellenv.sh)"
	./install-dev-packages.sh
	./install-uv-packages.sh
