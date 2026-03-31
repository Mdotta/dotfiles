export HOMEBREW_PREFIX="$(brew --prefix)"
export PATH="$HOMEBREW_PREFIX/bin:$PATH"
export LANG="en_US.UTF-8"
# export PATH="/Users/mateusdotta/.local/bin:$PATH"
# If you want HOMEBREW_PREFIX reliably:
# eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"