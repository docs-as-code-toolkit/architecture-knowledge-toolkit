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

Cross-engine helper that runs an agent session on a clone of a repository which
**cannot publish anything**, so skills that push branches or create issues can
act for real — in a demonstration, a workshop, or a first look at an unfamiliar
project. The guarantee comes from a process sandbox around the session, not from
an instruction to the agent.

### Requirements

- The [Anthropic Sandbox Runtime](https://github.com/anthropics/sandbox-runtime):
  `npm install -g @anthropic-ai/sandbox-runtime`, which provides `srt`. Without
  it, `start`, `login` and `check` refuse to run.
- Node.js, which writes the sandbox policy (it is already there once `srt` is).
- On macOS, `ripgrep`. On Linux, `bubblewrap`, `socat` and `ripgrep`; see the
  runtime's documentation for distribution-specific notes.

### Usage

```bash
./dry-run-session.sh setup <source> [target]      # clone into a locked-down directory
./dry-run-session.sh login <target>               # log Claude Code in, once per clone
./dry-run-session.sh check <target>               # prove the boundary on this machine
./dry-run-session.sh start <target>               # run Claude Code inside the session
./dry-run-session.sh start <target> -- <cmd ...>  # ... or any other command
```

`<source>` is a local checkout or a clone URL; `<target>` defaults to
`<name>-dry-run` in the current directory. Set `ARCHITECTURE_KNOWLEDGE_TOOLKIT`
before `start` when the clone lives outside the toolkit's parent directory, so
the session inherits it.

| Variable | Default | Purpose |
|---|---|---|
| `DRY_RUN_ALLOWED_DOMAINS` | `api.anthropic.com *.anthropic.com claude.ai claude.com *.claude.com` | Domains the session may reach, separated by spaces. Set it for an agent other than Claude Code. |
| `DRY_RUN_SESSION_SRT` | `srt` | The sandbox runtime to use. |

### Behavior

- **A process sandbox around the whole session.** `start` runs the command
  through `srt` with a policy written for this session, outside every writable
  path. The session writes only to the clone and to the temporary directories of
  `srt` and Claude Code (`/tmp/claude`, `/tmp/claude-<uid>` and `/tmp/claude-*`).
  It cannot read `~/.ssh`, the `gh` and `glab` configuration, `~/.netrc`,
  `~/.git-credentials`, `~/.claude` or `~/.claude.json`, and it reaches only the
  allowed domains. GitHub and GitLab are denied explicitly, and a denial wins over
  an allowance, so they stay unreachable even with `DRY_RUN_ALLOWED_DOMAINS="*"`.
- **Claude Code state stays with the clone.** The session runs with
  `CLAUDE_CONFIG_DIR` set to `.git/dry-run-session/claude` inside the clone.
  Settings, hooks, history and `.claude.json` written during a dry run live there
  and are discarded with the clone; no session outside the dry run reads them.
  Claude Code ties its login to that directory, so log in once per clone with
  `login`. The login is the only run allowed to bind a local port, which the
  OAuth callback needs.
- **The session cannot loosen its guards.** The sandbox keeps the clone's hook
  directory, its `.git/config` and `.claude/settings.local.json` unwritable.
- **A clone of its own.** The original checkout is never touched. The clone's
  push URL is unusable, and a `pre-push` hook installed through a clone-local
  `core.hooksPath` rejects every push, including a push to an explicitly named
  URL.
- **A session without credentials.** `start` removes `GH_TOKEN`, `GITHUB_TOKEN`,
  `GH_ENTERPRISE_TOKEN`, `GITLAB_TOKEN`, `GLAB_TOKEN` and the SSH agent socket,
  points `gh` and `glab` at empty configuration, sets `GIT_SSH_COMMAND=false`,
  resets every git credential helper, and disables terminal prompts.
- **Deny rules for Claude Code**, written to `.claude/settings.local.json` when
  that file does not exist yet. An existing file is reported and left untouched,
  never merged.
- **`check` tests the sandbox, not the layers around it.** From inside the
  session it pushes to `origin` and to a local repository, with and without the
  hook, writes outside the clone, changes the clone's git configuration and hook,
  pushes over HTTPS with the credential helpers restored and over SSH with SSH
  restored, to GitHub and to GitLab, calls `gh` with its own configuration, reads
  `~/.ssh`, and writes to and reads `~/.claude`. Every target either does not
  exist or is thrown away, so even a failing boundary publishes nothing. Each
  probe must fail for the right reason: one that fails only because a remote
  answered without the target or the key is reported as `OPEN`. `check` also
  reports whether Claude Code is logged in for the clone. Use a clone only when
  `check` ends with `RESULT: tight`.

The clone guards, the credential removal and the deny rules are each something a
determined agent could undo from inside an unsandboxed session: `git push
--no-verify` skips the hook, `env -u` restores a credential helper, and the
original checkout is one `cd` away. They stay because they turn a mistake into a
clear message; the guarantee rests on the sandbox.

### What it does not do

- **It does not inspect what goes to an allowed domain.** The agent sends what
  it reads to its own API, as in any session. That is not a publication to the
  project, but anything added to `DRY_RUN_ALLOWED_DOMAINS` is reachable with
  whatever the session can read.
- **The macOS login keychain stays readable**, because Claude Code keeps its
  login there. A credential found in it cannot reach GitHub or GitLab, but it
  could reach an allowed domain.
- **User-level Claude Code configuration does not apply.** Settings, skills,
  agents and `CLAUDE.md` from `~/.claude` are not available inside a dry run; the
  project's own configuration is.
- **The login run can bind local ports**, and on macOS that also lets it reach
  services on the loopback interface. It runs only `claude auth login`; log in
  right after `setup`, before a session has written to the clone.
- **Claude Code's temporary directory `/tmp/claude-<uid>`** is shared with the
  user's other Claude Code sessions and stays writable.
- **GitHub and GitLab are not readable either.** `gh`, `glab` and the public APIs
  are unreachable from inside the session. Put the text of an issue into the
  prompt, or into a file before `start`.
- **It is verified on macOS only**, with version 0.0.76 of the runtime and
  Claude Code 2.1.270. The policy is written for Linux as well, but the runtime
  supports path globs only on macOS; run `check` before relying on it. Windows is
  not supported.
- A `check` result holds for the machine it ran on.
- Local commits and file changes inside the clone are not blocked. That is the
  point: the clone can act freely and be discarded afterwards.
