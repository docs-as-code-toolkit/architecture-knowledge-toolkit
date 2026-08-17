#!/usr/bin/env bash
#
# Reference, don't copy: symlink the toolkit's exposed skills into an
# OpenCode skill root so OpenCode's native skill tool discovers them while the
# canonical SKILL.md files stay in the toolkit.
#
# Usage:
#   ./install-skills.sh                 # -> ~/.config/opencode/skills
#   ./install-skills.sh --agents        # -> ~/.agents/skills (shared: pi/Claude/OpenCode)
#   ./install-skills.sh --root <dir>    # -> <dir>
#
# Skips helper skills marked adapter_expose: false and non-skill dirs.

set -euo pipefail

TOOLKIT="${ARCHITECTURE_KNOWLEDGE_TOOLKIT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
ROOT="${HOME}/.config/opencode/skills"

case "${1:-}" in
  --agents) ROOT="${HOME}/.agents/skills" ;;
  --root) ROOT="${2:?--root requires a directory}"; shift ;;
esac

mkdir -p "$ROOT"

for skill in "$TOOLKIT"/skills/*/SKILL.md; do
  [ -f "$skill" ] || continue
  name="$(basename "$(dirname "$skill")")"
  if grep -q '^adapter_expose:[[:space:]]*false' "$skill"; then
    printf 'skip (adapter_expose: false): %s\n' "$name"
    continue
  fi
  ln -sfn "$(dirname "$skill")" "$ROOT/$name"
  printf 'linked %s\n' "$name"
done

printf '\nOpenCode skills installed in: %s\n' "$ROOT"
