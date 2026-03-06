# ~/.zshrc (symlinked here from $HOME)
ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

if [[ -d "$ZSH_CONFIG_DIR" ]]; then
  for f in "$ZSH_CONFIG_DIR"/*.zsh(N); do
    source "$f"
  done
fi