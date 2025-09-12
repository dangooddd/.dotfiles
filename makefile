STOW_DIR := stow

all:
	cd $(STOW_DIR) && stow --no-folding -v -t ~ *

clean:
	cd $(STOW_DIR) && stow --no-folding -D -v -t ~ *
