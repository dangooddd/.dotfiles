# LSP setup
Guide for helix lsp setup.


## Python

Those packages is required for correct work of
yapf python formatter and flake8 linter:
```sh
sudo dnf in python3-lsp-server \
    python3-yapf \
    python3-flake8 \
    python3-whatthepatch \
    --exclude=black
```
