# Dotfiles

Personal dotfiles repo for zsh (modular config) on macOS.

This repo is intended to be cloned onto a new machine and installed via a single script, which creates symlinks into the expected locations:

- `~/.config/zsh` → `<repo>/zsh`
- `~/.zshrc` → `<repo>/zshrc`

## Prerequisites (macOS)

1. Install Xcode Command Line Tools:
   ```sh
   xcode-select --install
   ```

2. Install Homebrew (if you don't have it):
   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. (Optional but recommended) Install the VS Code `code` CLI:
   - Open VS Code
   - Command Palette → `Shell Command: Install 'code' command in PATH`

## Clone the repo

Choose a location for your dotfiles (example uses `~/dotfiles`):

```sh
git clone git@github.com:Mdotta/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

## Install

1. Make the installer executable:
   ```sh
   chmod +x install.sh
   ```

2. (Recommended) Back up your existing `~/.zshrc`:
   ```sh
   cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d-%H%M%S) 2>/dev/null || true
   ```

3. Run the installer:
   ```sh
   ./install.sh
   ```

4. Restart your shell:
   ```sh
   exec zsh
   ```

## What `install.sh` does

Creates/updates symlinks:

- `~/.config/zsh` points to `~/dotfiles/zsh`
- `~/.zshrc` points to `~/dotfiles/zshrc`

To verify:

```sh
ls -la ~/.config/zsh
ls -la ~/.zshrc
```

## Installing shell dependencies

These dotfiles may rely on some tools being installed. Recommended packages:

```sh
brew install zsh fzf fd bat ripgrep eza starship zinit
```

Notes:
- `fzf` is also usable without these extras, but `fd`/`bat`/`ripgrep` improve speed and previews.
- `zinit` path in your config assumes a Homebrew install. If your config sources zinit via `$HOMEBREW_PREFIX`, ensure Homebrew is set up (e.g. `eval "$(/opt/homebrew/bin/brew shellenv)"` in `zsh/10-env.zsh` if needed).

## Repo structure

- `zsh/`  
  Modular zsh config files (loaded in lexicographic order, typically prefixed with numbers like `10-...`, `20-...`).

- `zshrc`  
  The `~/.zshrc` entrypoint (symlinked into `$HOME`) which loads `~/.config/zsh/*.zsh`.

- `install.sh`  
  Installer that creates symlinks.

## Uninstall / rollback

To remove the symlinks:

```sh
rm -f ~/.zshrc
rm -f ~/.config/zsh
```

If you created a backup `~/.zshrc.backup.*`, you can restore it:

```sh
cp ~/.zshrc.backup.YYYYMMDD-HHMMSS ~/.zshrc
exec zsh
```

## Troubleshooting

### `command not found: brew` or `$HOMEBREW_PREFIX` issues
Ensure Homebrew is installed and your PATH is set. For Apple Silicon macs, Homebrew is usually at `/opt/homebrew`.

### Completion / tab completion issues
If completions act strangely after changes:

```sh
rm -f ~/.zcompdump*
exec zsh
```

### VS Code helpers not working (`code: command not found`)
Install the VS Code shell command from within VS Code:
Command Palette → `Shell Command: Install 'code' command in PATH`