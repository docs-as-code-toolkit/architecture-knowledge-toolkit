# Shared

## Skill Installer (`install-skills.sh`)

Cross-engine helper that references the toolkit's skills into an agent's
native `SKILL.md` discovery root via symlinks — **reference, don't copy**: the
canonical skill files stay in the toolkit, and re-running the installer picks
up any toolkit updates.

### Usage

```bash
./install-skills.sh [install] [claude]   # project: .agents/skills (default) or .claude/skills
./install-skills.sh remove  [claude]     # remove installed toolkit symlinks
./install-skills.sh -g [claude]          # global: ~/.agents/skills or ~/.claude/skills
./install-skills.sh --root <dir>         # arbitrary SKILL.md harness root
```

Project-local is the default: it targets `.agents/skills` in the git worktree
root (or the current directory outside a git repo). Pass `-g`/`--global` to
install into the user-global root instead.

| Mode | Root | Read by |
|------|------|---------|
| default (project) | `.agents/skills` (git root) | Codex, Cursor, OpenCode, pi, Vibe |
| `claude` (project) | `.claude/skills` (git root) | Claude Code, OpenCode |
| `-g` / `--global` | `~/.agents/skills` | user-wide for Codex, Cursor, OpenCode, pi, Vibe |
| `-g claude` | `~/.claude/skills` | user-wide for Claude Code, OpenCode |
| `--root` | any directory | any SKILL.md harness |
| `remove` | same root selection | removes only toolkit symlinks |

### Behavior

- Symlinks each exposed skill directory into the chosen root.
- Skips helper skills marked `adapter_expose: false` and non-skill dirs.
- `ARCHITECTURE_KNOWLEDGE_TOOLKIT` overrides the toolkit location.
- Symlinked entries are generated artifacts, not committed source; keep them
  out of version control.
- `remove` deletes only symlinks whose target is the toolkit, so
  project-authored custom skills in the same root are never touched.
- Re-run after a toolkit update; pin a stable toolkit tag for reproducibility.
