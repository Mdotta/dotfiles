codex-commit-msg() {
  emulate -L zsh
  setopt pipefail no_unset

  local repo_root staged_files diff_file prompt_file output_file err_file raw_output message line
  local codex_pid codex_status spinner_i
  local -a spinner_chars
  local conventional_re='^(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\([[:alnum:]._-]+\))?!?: .+'

  if ! command -v git >/dev/null 2>&1; then
    print -u2 "git is required."
    return 1
  fi

  if ! command -v codex >/dev/null 2>&1; then
    print -u2 "codex CLI is required."
    return 1
  fi

  if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    print -u2 "Run this inside a git repository."
    return 1
  fi

  if git diff --cached --quiet; then
    print -u2 "No staged changes found. Stage files first."
    return 1
  fi

  repo_root=$(git rev-parse --show-toplevel) || return 1
  staged_files=$(git diff --cached --name-only)
  diff_file=$(mktemp)
  prompt_file=$(mktemp)
  output_file=$(mktemp)
  err_file=$(mktemp)

  {
    git diff --cached --unified=0 --no-color >"$diff_file"

    cat >"$prompt_file" <<EOF
Write exactly one Conventional Commit subject line for the staged git changes.

Rules:
- Output exactly one line and nothing else.
- Follow Conventional Commits: type(scope): summary
- Allowed types: feat, fix, docs, style, refactor, test, chore, ci, build, perf, revert
- Use a scope only if it is clearly supported by the filenames or diff.
- Keep the subject in imperative mood.
- Keep it under 72 characters if possible.
- Do not wrap in quotes, markdown, or code fences.
- Do not mention ticket numbers unless they appear clearly in the staged changes.

Repository root:
$repo_root

Staged files:
$staged_files

Staged diff:
EOF

    cat "$diff_file" >>"$prompt_file"

    codex exec \
      --ephemeral \
      --sandbox read-only \
      --cd "$repo_root" \
      --output-last-message "$output_file" \
      - <"$prompt_file" >/dev/null 2>"$err_file" &
    codex_pid=$!

    spinner_chars=('|' '/' '-' '\\')
    spinner_i=1
    if [[ -t 2 ]]; then
      while kill -0 "$codex_pid" 2>/dev/null; do
        printf '\rGenerating commit message... %s' "${spinner_chars[$spinner_i]}" >&2
        spinner_i=$((spinner_i % ${#spinner_chars} + 1))
        sleep 0.1
      done
      wait "$codex_pid"
      codex_status=$?
      printf '\r\033[K' >&2
    else
      wait "$codex_pid"
      codex_status=$?
    fi

    if (( codex_status != 0 )); then
      print -u2 "codex exec failed while generating the commit message."
      [[ -s "$err_file" ]] && cat "$err_file" >&2
      return 1
    fi

    raw_output=$(<"$output_file")
    message=''
    for line in ${(f)raw_output}; do
      line=${line//$'\r'/}
      line=${line#\"}
      line=${line%\"}
      [[ -z "$line" ]] && continue
      [[ "$line" == '```'* ]] && continue

      if print -r -- "$line" | grep -Eq "$conventional_re"; then
        message="$line"
        break
      fi
    done

    if [[ -z "$message" ]]; then
      print -u2 "Codex returned an invalid Conventional Commit subject:"
      print -u2 "$raw_output"
      return 1
    fi

    print -r -- "$message"
  } always {
    rm -f "$diff_file" "$prompt_file" "$output_file" "$err_file"
  }
}

# Preview a generated commit message, allow an edit, then commit the staged changes.
codex-commit() {
  emulate -L zsh
  setopt pipefail no_unset

  local message reply

  message=$(codex-commit-msg) || return 1

  print "Suggested commit message:"
  print "  $message"
  vared -p "Edit message or press Enter to keep it: " -c message

  if [[ -z "$message" ]]; then
    print -u2 "Commit message cannot be empty."
    return 1
  fi

  print -n "Commit staged changes with this message? [y/N] "
  read -r reply
  if [[ "$reply" == [Yy] ]]; then
    git commit -m "$message"
  else
    print "Commit canceled."
  fi
}

# Short aliases for faster typing.
alias ccm='codex-commit'
alias ccmsg='codex-commit-msg'