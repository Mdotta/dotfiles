# Git + fzf helpers
# Requires: git, fzf
# Optional: bat for previews, VS Code `code` CLI for opening files

_git_root() {
  git rev-parse --show-toplevel 2>/dev/null
}

gbr() {
  git rev-parse --git-dir >/dev/null 2>&1 || { echo "Not in a git repo"; return 1; }

  local branch
  branch="$(
    git for-each-ref --sort=-committerdate \
      --format='%(refname:short)' refs/heads refs/remotes \
    | sed 's#^origin/##' \
    | awk '!seen[$0]++' \
    | fzf --prompt='Branch> ' --height=40% --layout=reverse
  )" || return

  git checkout "$branch"
}

glog() {
  git rev-parse --git-dir >/dev/null 2>&1 || { echo "Not in a git repo"; return 1; }

  local sel sha
  sel="$(
    git log --date=short --pretty=format:'%C(auto)%h %C(blue)%ad%C(reset) %s %C(black)%an%C(reset)%C(auto)%d%C(reset)' \
    | fzf --ansi --no-sort --prompt='Commit> ' \
          --preview 'echo {} | awk "{print \$1}" | xargs -I@ git show --color=always @ | sed -n "1,200p"' \
          --preview-window=right,70%
  )" || return

  sha="$(echo "$sel" | awk '{print $1}')"
  git show "$sha" | less -R
}

# gfile: fuzzy pick a file and open in VS Code
# Usage:
#   gfile            -> tracked files only
#   gfile -a|--all   -> tracked + untracked (respects .gitignore)
#   gfile -A         -> tracked + untracked + ignored
gfile() {
  git rev-parse --git-dir >/dev/null 2>&1 || { echo "Not in a git repo"; return 1; }

  local root mode
  root="$(_git_root)" || return 1
  mode="${1:-}"

  local cmd
  case "$mode" in
    "" )
      cmd='git ls-files'
      ;;
    -a|--all )
      # tracked + untracked (excluding ignored)
      cmd='git ls-files --cached --others --exclude-standard'
      ;;
    -A )
      # tracked + untracked + ignored
      cmd='git ls-files --cached --others -i --exclude-standard; git ls-files --cached --others --exclude-standard'
      ;;
    * )
      echo "Usage: gfile [-a|--all|-A]"
      return 2
      ;;
  esac

  local file
  file="$(
    (cd "$root" && eval "$cmd") \
      | awk 'NF' \
      | awk '!seen[$0]++' \
      | fzf --prompt='Repo file> ' \
            --preview "bat --style=numbers --color=always --line-range :200 '$root/{}' 2>/dev/null || sed -n '1,200p' '$root/{}'" \
            --preview-window=right,70%
  )" || return

  code --goto "$root/$file"
}