alias d-c='docker compose'
alias gs='git status'

reload_ssh(){
  eval "$(ssh-agent -s)"
  ssh-add --apple-use-keychain ~/.ssh/id_ed25519_gitlab
  ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github
}

gacp(){
  local message="$*"

  if [[ -z "$message" ]]; then
    echo 'Usage: gacp "commit message"'
    return 1
  fi

  git add . && git commit -m "$message" && git push
}

gopen(){
  local add_pipelines=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p|--pipelines)
        add_pipelines=1
        shift
        ;;
      -h|--help)
        echo 'Usage: gopen [-p|--pipelines]'
        return 0
        ;;
      *)
        echo "Unknown option: $1"
        echo 'Usage: gopen [-p|--pipelines]'
        return 1
        ;;
    esac
  done

  local git_url=$(git remote get-url origin)

  local rest="${git_url#*@}"      # remove everything up to and including @
  local host="${rest%%:*}"        # take everything before :
  local repo_path="${rest#*:}"         # take everything after :
  repo_path="${repo_path%.git}"       # remove trailing .git

  local full_url="https://$host/$repo_path"
  if ((add_pipelines)); then
    full_url="$full_url/pipelines"
  fi

  open $full_url
}

fuzzy() {
  local -a cmd=( "$@" )
  local sel
  sel="$(command "${cmd[@]}" | fzf)" || return $?
  printf '%s\n' "$sel"
}