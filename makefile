STOW_DIR := stow
SCRIPT_DIR := script

all:
	cd $(STOW_DIR) && stow --no-folding -v -t ~ *

clean:
	cd $(STOW_DIR) && stow --no-folding -D -v -t ~ *

arch:
	$(SCRIPT_DIR)/install-yay.sh
	$(SCRIPT_DIR)/install-arch-packages.sh
	$(SCRIPT_DIR)/install-flatpak-packages.sh

macos:
	$(SCRIPT_DIR)/install-brew.sh
	$(SCRIPT_DIR)/install-brew-packages.sh

dev:
	$(SCRIPT_DIR)/install-brew.sh
	$(SCRIPT_DIR)/install-dev-packages.sh
