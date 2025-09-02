STOW_DIR := stow

all:
	cd $(STOW_DIR) && stow -v -t ~ *

clean:
	cd $(STOW_DIR) && stow -D -v -t ~ *
