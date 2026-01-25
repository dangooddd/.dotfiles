stow_dir := stow
script_dir := script

all:
	cd $(stow_dir) && stow --no-folding -v -t ~ *

clean:
	cd $(stow_dir) && stow --no-folding -D -v -t ~ *

arch:
	$(script_dir)/install-yay.sh
	$(script_dir)/install-arch-packages.sh
	$(script_dir)/install-flatpak-packages.sh

macos:
	$(script_dir)/install-brew.sh
	$(script_dir)/install-brew-packages.sh

dev:
	$(script_dir)/install-brew.sh
	$(script_dir)/install-dev-packages.sh
