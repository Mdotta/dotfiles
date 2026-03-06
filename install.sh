#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$HOME/.config"

# Zsh modular config
ln -sfn "$DOTFILES_DIR/zsh" "$HOME/.config/zsh"

# .zshrc config
ln -sfn "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"

# Starship
ln -sfn "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

echo "Dotfiles installed."