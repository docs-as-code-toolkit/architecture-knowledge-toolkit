#!/usr/bin/env bash
#
# Run an agent session that can read a repository but cannot publish anything.
#
# Usage:
#   ./dry-run-session.sh setup <source> [target]      # clone into a locked-down directory
#   ./dry-run-session.sh check <target>               # prove that nothing gets out
#   ./dry-run-session.sh start <target> [-- cmd ...]  # run a command in the session (default: claude)
#
# <source> is a local checkout or a clone URL; <target> defaults to
# <name>-dry-run in the current directory.
#
# Hard layers:
#   - A clone of its own. Its push URL is unusable, and a pre-push hook installed
#     through a clone-local core.hooksPath rejects every push, including a push to
#     an explicitly named URL, which an unusable push URL alone would not stop.
#   - A session without credentials: no gh or glab login, no SSH agent, no SSH,
#     every git credential helper reset, no terminal prompts.
# Soft layer:
#   - Deny rules for Claude Code in .claude/settings.local.json. They match
#     commands as written; the guarantee rests on the hard layers.
#
# `check` attempts every write path against a target that does not exist, so even
# a failing layer publishes nothing, and requires the right reason for each
# failure: a probe that fails only because its target is missing is OPEN.
set -euo pipefail

SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
PUSH_URL_DISABLED="PUSH-DISABLED-dry-run-session"
HOOK_MESSAGE="dry-run-session: pushing is disabled in this clone"
SETTINGS=".claude/settings.local.json"

usage() {
  sed -n '3,11p' "$SELF" >&2
  exit 2
}

setup() {
  local src="${1:-}" dst name
  [ -n "$src" ] || usage
  name="$(basename "${src%.git}")"
  dst="${2:-$PWD/${name}-dry-run}"
  if [ -e "$dst" ]; then
    echo "Target already exists: $dst" >&2
    exit 1
  fi

  git clone --quiet "$src" "$dst"
  cd "$dst"

  git remote set-url --push origin "$PUSH_URL_DISABLED"
  mkdir -p .git/dry-run-hooks
  printf '#!/bin/sh\necho "%s" >&2\nexit 1\n' "$HOOK_MESSAGE" >.git/dry-run-hooks/pre-push
  chmod +x .git/dry-run-hooks/pre-push
  git config core.hooksPath .git/dry-run-hooks

  if [ -e "$SETTINGS" ]; then
    echo "  $SETTINGS already exists and was left untouched; add the deny rules by hand" >&2
  else
    mkdir -p .claude
    cat >"$SETTINGS" <<'JSON'
{
  "permissions": {
    "deny": [
      "Bash(git push)",
      "Bash(git push *)",
      "Bash(git remote set-url *)",
      "Bash(git config core.hooksPath *)",
      "Bash(git config --unset core.hooksPath)",
      "Bash(gh issue *)",
      "Bash(gh pr *)",
      "Bash(gh api *)",
      "Bash(gh auth *)",
      "Bash(glab *)"
    ]
  }
}
JSON
    if ! git check-ignore -q "$SETTINGS"; then
      echo "  note: $SETTINGS is not ignored by git in this project" >&2
    fi
  fi

  echo "set up: $dst"
  echo "  check: $SELF check \"$dst\""
  echo "  start: $SELF start \"$dst\""
}

start() {
  local dst="${1:-}" cfg
  [ -n "$dst" ] || usage
  shift
  if [ "${1:-}" = "--" ]; then shift; fi
  if [ "$#" -eq 0 ]; then set -- claude; fi
  cfg="$(mktemp -d)"
  cd "$dst"
  exec env \
    -u GH_TOKEN -u GITHUB_TOKEN -u GH_ENTERPRISE_TOKEN \
    -u GITLAB_TOKEN -u GLAB_TOKEN -u SSH_AUTH_SOCK \
    GH_CONFIG_DIR="$cfg/gh" GLAB_CONFIG_DIR="$cfg/glab" \
    GIT_CONFIG_NOSYSTEM=1 \
    GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=credential.helper GIT_CONFIG_VALUE_0= \
    GIT_TERMINAL_PROMPT=0 GIT_ASKPASS=false SSH_ASKPASS=false \
    GIT_SSH_COMMAND=false \
    "$@"
}

check() {
  local dst="${1:-}" out bare refs rc=0
  [ -n "$dst" ] || usage
  out="$(mktemp)"
  bare="$(mktemp -d)/target.git"
  git init --bare --quiet "$bare"

  # probe <description> <pattern the failure must show> <command...>
  probe() {
    local description="$1" expected="$2"
    shift 2
    if "$SELF" start "$dst" -- "$@" >"$out" 2>&1; then
      echo "  OPEN     $description: the command succeeded"
      rc=1
    elif grep -qiE "Repository not found|returned error: 403|denied to|Authentication failed for|could not be found|HTTP Basic: Access denied|not allowed to push" "$out"; then
      echo "  OPEN     $description: not blocked, only the target was missing"
      rc=1
    elif grep -qiE "$expected" "$out"; then
      echo "  blocked  $description"
    else
      echo "  UNCLEAR  $description: unexpected failure: $(tail -n 1 "$out")"
      rc=1
    fi
  }

  echo "Write paths (each must fail, and for the right reason):"
  probe "push to origin" "$PUSH_URL_DISABLED|does not appear to be a git repository" \
    git push origin HEAD
  probe "push to a local repository (hook)" "$HOOK_MESSAGE" \
    git push "$bare" HEAD:refs/heads/probe
  probe "push over SSH to GitHub" "Could not read from remote repository" \
    git push --no-verify git@github.com:dry-run-session-probe/does-not-exist.git HEAD
  probe "push over HTTPS to GitHub" "terminal prompts disabled|could not read Username" \
    git push --no-verify https://github.com/dry-run-session-probe/does-not-exist.git HEAD
  probe "push over SSH to GitLab" "Could not read from remote repository" \
    git push --no-verify git@gitlab.com:dry-run-session-probe/does-not-exist.git HEAD
  probe "push over HTTPS to GitLab" "terminal prompts disabled|could not read Username" \
    git push --no-verify https://gitlab.com/dry-run-session-probe/does-not-exist.git HEAD
  if command -v gh >/dev/null 2>&1; then
    probe "authenticated gh call" "gh auth login" gh api user
  else
    echo "  blocked  authenticated gh call (gh is not installed)"
  fi

  refs="$(git -C "$bare" for-each-ref | wc -l | tr -d ' ')"
  echo "  refs in the probe repository afterwards: $refs (must be 0)"
  [ "$refs" = 0 ] || rc=1

  echo "Read paths (each must work):"
  if "$SELF" start "$dst" -- git log -1 --format=%h >/dev/null 2>&1; then
    echo "  ok       git log in the clone"
  else
    echo "  FAILED   git log in the clone"
    rc=1
  fi
  if "$SELF" start "$dst" -- curl -sf https://api.github.com/rate_limit >/dev/null 2>&1; then
    echo "  ok       public GitHub API without a token"
  else
    echo "  FAILED   public GitHub API without a token"
    rc=1
  fi

  rm -f "$out"
  if [ "$rc" = 0 ]; then
    echo "RESULT: tight"
  else
    echo "RESULT: NOT TIGHT, do not use this clone"
  fi
  return "$rc"
}

case "${1:-}" in
  setup) shift; setup "$@" ;;
  start) shift; start "$@" ;;
  check) shift; check "$@" ;;
  *) usage ;;
esac
