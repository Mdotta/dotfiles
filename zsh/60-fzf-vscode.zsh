# fzf + VS Code helpers
# Requires: fd, fzf, bat (optional), eza (optional), and VS Code `code` CLI

typeset -ga FZF_PROJECT_DIRS
FZF_PROJECT_DIRS=(
  "$HOME/code"
  "$HOME/Developer"
  "$HOME/src"
)

cproj() {
  local root dir
  local -a roots
  roots=()

  for root in "${FZF_PROJECT_DIRS[@]}"; do
    [[ -d "$root" ]] && roots+=("$root")
  done

  (( ${#roots[@]} == 0 )) && { echo "No project roots found. Set FZF_PROJECT_DIRS."; return 1; }

  dir="$(
    fd --type d --max-depth 4 --hidden --follow --exclude .git . "${roots[@]}" \
      | sed 's#/\.$##' \
      | fzf --prompt='Projects> ' \
            --preview 'eza -la --color=always --group-directories-first {} 2>/dev/null || ls -la {}' \
            --preview-window=right,60%
  )" || return

  code "$dir"
}

cfile() {
  local file
  file="$(
    fd --type f --hidden --follow --exclude .git . \
      | fzf --prompt='Files> ' \
            --preview 'bat --style=numbers --color=always --line-range :200 {} 2>/dev/null || sed -n "1,200p" {}' \
            --preview-window=right,60%
  )" || return

  code --goto "$file"
}