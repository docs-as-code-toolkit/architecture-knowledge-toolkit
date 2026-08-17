# Shared

## Skill Installer (`install-skills.sh`)

Cross-engine helper that references the toolkit's skills into an agent's
native `SKILL.md` discovery root via symlinks — **reference, don't copy**: the
canonical skill files stay in the toolkit, and re-running the installer picks
up any toolkit updates.

### Usage

```bash
./install-skills.sh [agents|claude]   # target; default: agents
./install-skills.sh --root <dir>      # arbitrary SKILL.md harness root
./install-skills.sh --all             # agents + claude
```

| Target  | Root                     | Read by                     |
|---------|--------------------------|-----------------------------|
| `agents` (default) | `~/.agents/skills` | OpenCode, pi |
| `claude` | `~/.claude/skills` | Claude Code, OpenCode |
| `--root` | any directory | any SKILL.md harness |

### Behavior

- Symlinks each exposed skill directory into the chosen root.
- Skips helper skills marked `adapter_expose: false` and non-skill dirs.
- `ARCHITECTURE_KNOWLEDGE_TOOLKIT` overrides the toolkit location.
- Re-run after a toolkit update; pin a stable toolkit tag for reproducibility.
