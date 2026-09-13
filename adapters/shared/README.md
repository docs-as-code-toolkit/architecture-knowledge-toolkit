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
./install-skills.sh --skills-dir <dir>   # arbitrary SKILL.md discovery root
./install-skills.sh --private-journal <dir>   # also bind the user's private journal
./install-skills.sh --no-private-journal      # ... or record that there is none
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
| `--skills-dir` | any directory | any SKILL.md harness |
| `remove` | same root selection | removes only toolkit symlinks |

### Behavior

- Symlinks each exposed skill directory into the chosen root.
- Skips helper skills marked `adapter_expose: false` and non-skill dirs.
- Never overwrites project-owned entries: existing files, directories, or
  foreign symlinks at a target path are left untouched and reported.
- `ARCHITECTURE_KNOWLEDGE_TOOLKIT` overrides the toolkit location.
- Symlinked entries are generated artifacts, not committed source; keep them
  out of version control.
- `remove` deletes only symlinks whose target is the toolkit, so
  project-authored custom skills in the same root are never touched.
- `--private-journal` / `--no-private-journal` delegate to `journal-config.sh`
  after linking. They apply to `install` only: uninstalling skills is not the
  same as giving up a journal.
- Re-run after a toolkit update; pin a stable toolkit tag for reproducibility.

## Private Journal Binding (`journal-config.sh`)

Records where the user's private journal repository lives, for the
[`clock-in`](../../skills/clock-in/SKILL.md) and
[`clock-out`](../../skills/clock-out/SKILL.md) skills.

A private journal is **per user, not per project**: its path differs on every
machine, so it must never be recorded in this toolkit or in a consuming
project. This helper keeps it in one user-level file instead.

### Usage

```bash
./journal-config.sh get                     # resolved binding; exit 3 if unbound
./journal-config.sh set --path <dir> [--clock-in <rel>] [--clock-out <rel>]
./journal-config.sh disable                 # record "no private journal"
./journal-config.sh forget                  # remove the binding, ask again
./journal-config.sh config-path             # where the binding is stored
```

`--config <file>` overrides the storage location for any of them.

### Resolution order

1. `ARCHITECTURE_KNOWLEDGE_TOOLKIT_JOURNAL` — a directory, or `off`.
2. `${XDG_CONFIG_HOME:-$HOME/.config}/architecture-knowledge-toolkit/journal.conf`.
3. Neither: exit `3`, meaning "ask the user once, then store the answer".

### Behavior

- `set` resolves the directory to an absolute path and discovers its clock
  skills, accepting an exact `clock-in` directory or a prefixed one such as
  `daily-clock-in`; an exact name wins. It refuses a directory where neither is
  found unless `--clock-in` / `--clock-out` name them explicitly.
- `disable` exists because **"I keep no private journal" is an answer worth
  storing.** Without it, a user without one is asked again every session, and
  the mechanism becomes the thing people work around.
- Both `set` and the environment override refuse a directory whose clock skills
  resolve into the toolkit — the journal would delegate to the skill that called
  it. This catches binding the toolkit itself and binding a project that
  installed the toolkit's skills into its own `skills/`. It cannot catch a
  journal holding its own delta file that defers upward in prose; that one is
  the skills' "Never delegate to yourself" rule.
- `get` still reports a binding whose checkout is absent on this machine and
  warns `unreachable` on stderr. The private layer never blocks the project
  layer.
- The file is plain `key=value` so a shell can read it without a JSON parser,
  and it is written with owner-only permissions because it names a private
  repository.

### Alternative: Vercel `skills` CLI

The [Vercel `skills` CLI](https://github.com/vercel-labs/skills)
(`npx skills add <source>`) can also install agent skills, and it supports
`.agents/skills` as the canonical universal root with per-agent dirs, symlink
by default, and a lock-based `update`/`remove` workflow.

It is **not** the default here because it vendors skills: it copies them into
the project's canonical copy rather than pointing at the toolkit checkout. That
contradicts this toolkit's "reference, don't copy" contract, it installs helper
skills too (no `adapter_expose` filter), and it adds a Node/npm + network
dependency.

Use it instead only when a consumer deliberately wants a pinned, self-contained
vendored copy with per-agent management — i.e. an explicit opt-out of the
"reference, don't copy" model.

Example (install the toolkit's skills from its public repo):

```bash
npx skills add docs-as-code-toolkit/architecture-knowledge-toolkit
```

Because the CLI installs every discovered skill, this also vendors the `grilling`
helper (which the installer above filters out via `adapter_expose`) — so prefer
`npx skills add <source> --list` to preview, then pick exposed skills with
`--skill`.

## Dry-Run Session (`dry-run-session.sh`)

Cross-engine helper that runs an agent session which can **read a repository
but cannot publish anything**, so skills that push branches or create issues can
act for real — in a demonstration, a workshop, or a first look at an unfamiliar
project. The guarantee comes from the environment, not from an instruction to
the agent.

### Usage

```bash
./dry-run-session.sh setup <source> [target]      # clone into a locked-down directory
./dry-run-session.sh check <target>               # prove that nothing gets out
./dry-run-session.sh start <target>               # run Claude Code inside the session
./dry-run-session.sh start <target> -- <cmd ...>  # ... or any other command
```

`<source>` is a local checkout or a clone URL; `<target>` defaults to
`<name>-dry-run` in the current directory. Set `ARCHITECTURE_KNOWLEDGE_TOOLKIT`
before `start` when the clone lives outside the toolkit's parent directory, so
the session inherits it.

### Behavior

- **A clone of its own.** The original checkout is never touched. The clone's
  push URL is unusable, and a `pre-push` hook installed through a clone-local
  `core.hooksPath` rejects every push — including a push to an explicitly named
  URL, which an unusable push URL alone would not stop.
- **A session without credentials.** `start` removes `GH_TOKEN`, `GITHUB_TOKEN`,
  `GH_ENTERPRISE_TOKEN`, `GITLAB_TOKEN`, `GLAB_TOKEN` and the SSH agent socket,
  points `gh` and `glab` at empty configuration, sets `GIT_SSH_COMMAND=false`,
  resets every git credential helper, and disables terminal prompts.
- **Deny rules for Claude Code**, written to `.claude/settings.local.json` when
  that file does not exist yet. This layer is soft — it matches commands as they
  are written — and an existing file is reported and left untouched, never
  merged. The guarantee rests on the two layers above.
- **`check` requires the right reason.** It attempts a push to `origin`, to a
  local repository, and over SSH and HTTPS to GitHub and GitLab, plus an
  authenticated `gh` call — always against targets that do not exist, so even a
  failing layer publishes nothing. A probe that fails only because its target is
  missing is reported as `OPEN`, not as blocked. Use a clone only when `check`
  ends with `RESULT: tight`.

### What it does not do

- `gh` reads nothing inside the session, not even public issues. Read them
  through the public REST API — 60 unauthenticated requests per hour per IP — or
  paste the text into the prompt.
- The deny rules apply to Claude Code only; other agents get the two hard
  layers.
- A `check` result holds for the machine it ran on.
- Local commits and file changes inside the clone are not blocked. That is the
  point: the clone can act freely and be discarded afterwards.
