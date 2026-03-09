alias rider='open -na "Rider.app" --args'

rproj() {
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
      | fzf --prompt='Rider Repos> ' \
            --preview 'eza -la --color=always --group-directories-first {} 2>/dev/null || ls -la {}' \
            --preview-window=right,60%
  )" || return

  rider "$dir"
}
