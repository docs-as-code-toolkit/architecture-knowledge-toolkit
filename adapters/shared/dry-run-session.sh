#!/usr/bin/env bash
#
# Run an agent session on a clone of a repository that cannot publish anything.
#
# Usage:
#   ./dry-run-session.sh setup <source> [target]      # clone into a locked-down directory
#   ./dry-run-session.sh check <target>               # prove the boundary on this machine
#   ./dry-run-session.sh start <target> [-- cmd ...]  # run a command in the session (default: claude)
#
# <source> is a local checkout or a clone URL; <target> defaults to
# <name>-dry-run in the current directory. `start` and `check` need the
# Anthropic Sandbox Runtime (`srt`, npm package @anthropic-ai/sandbox-runtime).
#
# The boundary is a process sandbox around the whole session (srt). The session
# writes only to the clone and to the agent's own state, cannot read SSH keys or
# gh, glab and git credential files, and reaches only the agent's API. GitHub and
# GitLab stay denied even when more domains are allowed.
#
# Further layers, each of which a determined agent could undo on its own:
#   - A clone of its own with an unusable push URL and a pre-push hook installed
#     through a clone-local core.hooksPath. The sandbox keeps both unwritable.
#   - A session environment without tokens, SSH agent, SSH or credential helpers.
#   - Deny rules for Claude Code in .claude/settings.local.json.
#
# `check` attempts every write path from inside the session, undoes the further
# layers where a probe can, and aims only at targets that do not exist or are
# thrown away, so the sandbox itself is what gets tested and even a failing
# boundary publishes nothing. It requires the right reason for each failure.
set -euo pipefail

SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
PUSH_URL_DISABLED="PUSH-DISABLED-dry-run-session"
HOOK_MESSAGE="dry-run-session: pushing is disabled in this clone"
SETTINGS=".claude/settings.local.json"
SRT="${DRY_RUN_SESSION_SRT:-srt}"
DEFAULT_DOMAINS="api.anthropic.com *.anthropic.com claude.ai"
PROBE_REPOSITORY="dry-run-session-probe/does-not-exist.git"

usage() {
  sed -n '3,12p' "$SELF" >&2
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

require_sandbox() {
  if ! command -v "$SRT" >/dev/null 2>&1; then
    echo "dry-run-session: the sandbox runtime '$SRT' was not found; no session starts without it" >&2
    echo "  install it with: npm install -g @anthropic-ai/sandbox-runtime" >&2
    exit 1
  fi
  if ! command -v node >/dev/null 2>&1; then
    echo "dry-run-session: node is required to write the sandbox policy" >&2
    exit 1
  fi
}

# write_policy <clone> <file>: the srt settings for one session. The file lies
# outside every writable path, so the session cannot loosen its own policy.
write_policy() {
  # The node program is single-quoted on purpose; it reads its input from the environment.
  # shellcheck disable=SC2016
  DRY_RUN_CLONE="$1" DRY_RUN_POLICY="$2" DRY_RUN_UID="$(id -u)" \
    DRY_RUN_DOMAINS="${DRY_RUN_ALLOWED_DOMAINS:-$DEFAULT_DOMAINS}" \
    node -e '
const fs = require("node:fs");
const clone = process.env.DRY_RUN_CLONE;
const macOS = process.platform === "darwin";
// srt assigns /tmp/claude. Claude Code keeps its session directories below
// /tmp/claude-<uid> and a working-directory file next to it as /tmp/claude-*;
// a glob covers only the latter, a plain path the whole tree. Only macOS
// supports globs.
const uid = process.env.DRY_RUN_UID;
const temporary = macOS
  ? ["/tmp/claude", "/private/tmp/claude"].flatMap((dir) => [dir, `${dir}-${uid}`, `${dir}-*`])
  : ["/tmp/claude", `/tmp/claude-${uid}`];
const policy = {
  network: {
    allowedDomains: process.env.DRY_RUN_DOMAINS.split(/\s+/).filter(Boolean),
    // A denial wins over an allowance, so these hold whatever is allowed.
    deniedDomains: [
      "github.com", "*.github.com", "githubusercontent.com", "*.githubusercontent.com",
      "gitlab.com", "*.gitlab.com",
    ],
  },
  filesystem: {
    denyRead: ["~/.ssh", "~/.config/gh", "~/.config/glab-cli", "~/.netrc", "~/.git-credentials"],
    // The clone, the temporary directories srt and Claude Code use, and Claude Code state.
    allowWrite: [
      clone,
      ...temporary,
      "~/.claude",
      "~/.claude.json",
      ...(macOS ? ["~/.claude.json.*"] : []),
    ],
    // The clone guards, and everything that would change a later session.
    denyWrite: [
      `${clone}/.git/dry-run-hooks`,
      `${clone}/.claude/settings.local.json`,
      "~/.claude/settings.json",
      "~/.claude/settings.local.json",
      "~/.claude/CLAUDE.md",
      "~/.claude/hooks",
      "~/.claude/skills",
      "~/.claude/agents",
      "~/.claude/commands",
      "~/.claude/plugins",
    ],
  },
};
fs.writeFileSync(process.env.DRY_RUN_POLICY, JSON.stringify(policy, null, 2) + "\n");
'
}

start() {
  local dst="${1:-}" cfg clone
  [ -n "$dst" ] || usage
  shift
  if [ "${1:-}" = "--" ]; then shift; fi
  if [ "$#" -eq 0 ]; then set -- claude; fi
  require_sandbox
  clone="$(cd "$dst" && pwd -P)"
  cfg="$(mktemp -d)"
  write_policy "$clone" "$cfg/srt-settings.json"
  mkdir -p /tmp/claude 2>/dev/null || true
  cd "$clone"
  exec env \
    -u GH_TOKEN -u GITHUB_TOKEN -u GH_ENTERPRISE_TOKEN \
    -u GITLAB_TOKEN -u GLAB_TOKEN -u SSH_AUTH_SOCK \
    GH_CONFIG_DIR="$cfg/gh" GLAB_CONFIG_DIR="$cfg/glab" \
    GIT_CONFIG_NOSYSTEM=1 \
    GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=credential.helper GIT_CONFIG_VALUE_0= \
    GIT_TERMINAL_PROMPT=0 GIT_ASKPASS=false SSH_ASKPASS=false \
    GIT_SSH_COMMAND=false \
    "$SRT" --settings "$cfg/srt-settings.json" -- "$@"
}

check() {
  local dst="${1:-}" out scratch bare refs api code rc=0
  [ -n "$dst" ] || usage
  require_sandbox
  out="$(mktemp)"
  scratch="$(mktemp -d)"
  bare="$scratch/target.git"
  git init --bare --quiet "$bare"

  # probe <description> <pattern the failure must show> <command...>
  probe() {
    local description="$1" expected="$2"
    shift 2
    if "$SELF" start "$dst" -- "$@" >"$out" 2>&1 </dev/null; then
      echo "  OPEN     $description: the command succeeded"
      rc=1
    elif grep -qiE "Repository not found|returned error: 403|denied to|Authentication failed for|could not be found|HTTP Basic: Access denied|not allowed to push|Permission denied \(publickey|Host key verification failed" "$out"; then
      echo "  OPEN     $description: a remote answered, only the target or the key was missing"
      rc=1
    elif grep -qiE "$expected" "$out"; then
      echo "  blocked  $description"
    else
      echo "  UNCLEAR  $description: unexpected failure: $(tail -n 1 "$out")"
      rc=1
    fi
  }

  local restore_helpers=(env -u GIT_CONFIG_COUNT -u GIT_CONFIG_KEY_0 -u GIT_CONFIG_VALUE_0 -u GIT_CONFIG_NOSYSTEM)
  local restore_ssh=(env "GIT_SSH_COMMAND=ssh -o BatchMode=yes -o ConnectTimeout=10")
  local denied="Operation not permitted|Permission denied|Read-only file system"
  local unreachable="CONNECT tunnel failed|Could not resolve host|Operation not permitted|Connection refused"

  echo "Write paths (each must fail, and for the right reason):"
  probe "push to origin" "$PUSH_URL_DISABLED|does not appear to be a git repository" \
    git push origin HEAD
  probe "push to a local repository (hook)" "$HOOK_MESSAGE" \
    git push "$bare" HEAD:refs/heads/probe
  probe "push to a local repository, hook bypassed" "unable to create temporary object directory|$denied" \
    git push --no-verify "$bare" HEAD:refs/heads/probe
  probe "write outside the clone" "$denied" \
    touch "$scratch/outside"
  probe "change the clone's git configuration" "could not (write|lock) config file|$denied" \
    git config remote.origin.pushurl https://example.invalid/probe.git
  probe "change the pre-push hook" "$denied" \
    touch .git/dry-run-hooks/pre-push
  probe "HTTPS to GitHub, credential helpers restored" "$unreachable" \
    "${restore_helpers[@]}" git push --no-verify "https://github.com/$PROBE_REPOSITORY" HEAD
  probe "HTTPS to GitLab, credential helpers restored" "$unreachable" \
    "${restore_helpers[@]}" git push --no-verify "https://gitlab.com/$PROBE_REPOSITORY" HEAD
  probe "SSH to GitHub, SSH restored" "Could not resolve hostname|$unreachable" \
    "${restore_ssh[@]}" git push --no-verify "git@github.com:$PROBE_REPOSITORY" HEAD
  probe "SSH to GitLab, SSH restored" "Could not resolve hostname|$unreachable" \
    "${restore_ssh[@]}" git push --no-verify "git@gitlab.com:$PROBE_REPOSITORY" HEAD
  if command -v gh >/dev/null 2>&1; then
    probe "gh with its own configuration" "$unreachable|$denied" \
      env -u GH_CONFIG_DIR gh api user
  else
    echo "  blocked  gh with its own configuration (gh is not installed)"
  fi
  if [ -d "$HOME/.ssh" ]; then
    probe "read SSH keys" "$denied" ls "$HOME/.ssh"
  else
    echo "  blocked  read SSH keys (there is no ~/.ssh)"
  fi

  refs="$(git -C "$bare" for-each-ref | wc -l | tr -d ' ')"
  echo "  refs in the probe repository afterwards: $refs (must be 0)"
  [ "$refs" = 0 ] || rc=1
  if [ -e "$scratch/outside" ]; then
    echo "  a file was written outside the clone"
    rc=1
  fi

  echo "Read paths (each must work):"
  if "$SELF" start "$dst" -- git log -1 --format=%h >/dev/null 2>&1 </dev/null; then
    echo "  ok       git log in the clone"
  else
    echo "  FAILED   git log in the clone"
    rc=1
  fi
  api="$(printf '%s\n' "${DRY_RUN_ALLOWED_DOMAINS:-$DEFAULT_DOMAINS}" | tr -s '[:blank:]' '\n' | grep -v '[*]' | head -n 1 || true)"
  if [ -n "$api" ]; then
    code="$("$SELF" start "$dst" -- curl -s -o /dev/null -m 10 -w '%{http_code}' "https://$api/" 2>/dev/null </dev/null || true)"
    if [ -n "$code" ] && [ "$code" != 000 ]; then
      echo "  ok       the agent's API ($api answers HTTP $code)"
    else
      echo "  FAILED   the agent's API ($api is not reachable)"
      rc=1
    fi
  fi

  rm -rf "$out" "$scratch"
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
