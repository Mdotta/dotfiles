# fzf + VS Code helpers
# Requires: fd, fzf, bat (optional), eza (optional), and VS Code `code` CLI

typeset -ga FZF_PROJECT_DIRS
FZF_PROJECT_DIRS=(
  "$HOME/code"
  "$HOME/Developer"
  "$HOME/src"
)

# ... keep your header + FZF_PROJECT_DIRS ...

cproj() {
  local root dir
  local -a roots
  roots=()

  for root in "${FZF_PROJECT_DIRS[@]}"; do
    [[ -d "$root" ]] && roots+=("$root")
  done

  (( ${#roots[@]} == 0 )) && { echo "No project roots found. Set FZF_PROJECT_DIRS."; return 1; }

  dir="$(
    fd --hidden --follow --max-depth 6 --type d --type f --glob '.git' "${roots[@]}" 2>/dev/null \
      | while IFS= read -r gitentry; do
          echo "${gitentry:h}"
        done \
      | awk 'NF' | awk '!seen[$0]++' \
      | fzf --prompt='Repos> ' \
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

cprojfile() {
  local repo
  local -a roots
  roots=()

  for root in "${FZF_PROJECT_DIRS[@]}"; do
    [[ -d "$root" ]] && roots+=("$root")
  done
  (( ${#roots[@]} == 0 )) && { echo "No project roots found. Set FZF_PROJECT_DIRS."; return 1; }

  repo="$(
    fd --hidden --follow --max-depth 6 --type d --type f --glob '.git' "${roots[@]}" 2>/dev/null \
      | while IFS= read -r gitentry; do
          echo "${gitentry:h}"
        done \
      | awk 'NF' | awk '!seen[$0]++' \
      | fzf --prompt='Repo> ' \
            --preview 'eza -la --color=always --group-directories-first {} 2>/dev/null || ls -la {}' \
            --preview-window=right,60%
  )" || return

  local -a files
  if (cd "$repo" && git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    # Fast + respects git: tracked files only
    files=("${(@f)$(
      (cd "$repo" && git ls-files) \
        | fzf --multi --prompt='Repo files> ' \
              --preview "bat --style=numbers --color=always --line-range :200 '$repo/{}' 2>/dev/null || sed -n '1,200p' '$repo/{}'" \
              --preview-window=right,60%
    )}") || return
  else
    # Fallback: any files in directory tree
    files=("${(@f)$(
      fd --type f --hidden --follow --exclude .git . "$repo" \
        | sed "s#^$repo/##" \
        | fzf --multi --prompt='Repo files> ' \
              --preview "bat --style=numbers --color=always --line-range :200 '$repo/{}' 2>/dev/null || sed -n '1,200p' '$repo/{}'" \
              --preview-window=right,60%
    )}") || return
  fi

  (( ${#files[@]} == 0 )) && return 0

  # Open selected file(s)
  if (( ${#files[@]} == 1 )); then
    code --goto "$repo/${files[1]}"
  else
    local f
    local -a abs
    abs=()
    for f in "${files[@]}"; do
      abs+=("$repo/$f")
    done
    code "${abs[@]}"
  fi
}