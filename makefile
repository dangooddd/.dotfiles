STOW_DIR := stow
TARGET   := ~

all:
	cd $(STOW_DIR) && stow -v -t $(TARGET) *

clean:
	cd $(STOW_DIR) && stow -D -v -t $(TARGET) *
