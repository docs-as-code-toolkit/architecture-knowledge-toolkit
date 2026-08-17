#!/usr/bin/env bash
#
# Reference, don't copy: symlink the toolkit's exposed skills into an agent
# skill root so agent-native SKILL.md discovery sees them while the canonical
# skill files stay in the toolkit.
#
# Usage:
#   ./install-skills.sh [agents|claude]   # target; default: agents
#   ./install-skills.sh --root <dir>      # arbitrary SKILL.md harness root
#   ./install-skills.sh --all             # all known shared roots
#
# - agents -> ~/.agents/skills   (default; cross-engine: Codex, Cursor, OpenCode, pi, Vibe)
# - claude -> ~/.claude/skills   (Claude Code reads only .claude/skills)
#
# Skips helper skills marked adapter_expose: false and non-skill directories.
# Re-run after a toolkit update; pin a stable toolkit tag for reproducibility.

set -euo pipefail

TOOLKIT="${ARCHITECTURE_KNOWLEDGE_TOOLKIT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
ROOTS_AGENTS="${HOME}/.agents/skills"
ROOTS_CLAUDE="${HOME}/.claude/skills"

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

case "${1:-agents}" in
  agents) link_root "$ROOTS_AGENTS" ;;
  claude) link_root "$ROOTS_CLAUDE" ;;
  --root) link_root "${2:?--root requires a directory}" ;;
  --all)  link_root "$ROOTS_AGENTS"; link_root "$ROOTS_CLAUDE" ;;
  *)      echo "unknown target: $1" >&2; exit 2 ;;
esac
