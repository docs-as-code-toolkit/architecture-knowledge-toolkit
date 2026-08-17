#!/usr/bin/env bash
#
# Reference, don't copy: symlink the toolkit's exposed skills into a SKILL.md
# discovery root so agent-native skill discovery sees them while the canonical
# skill files stay in the toolkit.
#
# Usage:
#   ./install-skills.sh [claude]      # project: .agents/skills (default) or .claude/skills
#   ./install-skills.sh -g [claude]   # global: ~/.agents/skills or ~/.claude/skills
#   ./install-skills.sh --root <dir>  # arbitrary SKILL.md harness root
#
# Project-local is the default: it targets `.agents/skills` in the git worktree
# root (or the current directory outside a git repo). Pass -g/--global to
# install into the user-global `~/.agents/skills` instead.
#
# Skips helper skills marked adapter_expose: false and non-skill directories.
# The symlinked entries are generated artifacts, not committed source. Re-run
# after a toolkit update; pin a stable toolkit tag for reproducibility.

set -euo pipefail

TOOLKIT="${ARCHITECTURE_KNOWLEDGE_TOOLKIT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

link_root() {
  local root="$1" name
  mkdir -p "$root"
  for skill in "$TOOLKIT"/skills/*/SKILL.md; do
    [ -f "$skill" ] || continue
    name="$(basename "$(dirname "$skill")")"
    if grep -q '^adapter_expose:[[:space:]]*false' "$skill"; then
      printf 'skip (adapter_expose: false): %s\n' "$name"
      continue
    fi
    ln -sfn "$(dirname "$skill")" "$root/$name"
    printf 'linked %s -> %s\n' "$name" "$root"
  done
  printf 'installed into %s\n' "$root"
}

GLOBAL=false
TARGET=agents
ROOT=""

while [ $# -gt 0 ]; do
  case "$1" in
    -g|--global) GLOBAL=true ;;
    --root) ROOT="${2:?--root requires a directory}"; shift ;;
    agents|claude) TARGET="$1" ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

if [ -n "$ROOT" ]; then
  link_root "$ROOT"
elif [ "$GLOBAL" = true ]; then
  link_root "${HOME}/.${TARGET}/skills"
else
  proj="$PWD"
  if toplevel="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    proj="$toplevel"
  fi
  link_root "$proj/.${TARGET}/skills"
fi
