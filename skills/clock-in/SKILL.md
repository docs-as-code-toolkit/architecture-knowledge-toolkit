---
name: clock-in
description: Start a working session from repository evidence instead of memory, pick up one topic, and orient both the project layer and the user's private journal. Use at the beginning of a day, when resuming after an interruption, when the user says clock in, or when starting a topic that will span more than one session.
---

# Clock In

## Purpose

Resume work without depending on what anyone remembers.

A session that starts by asking "where were we?" gets an answer built from
memory. This skill starts from the repository instead, and only then asks the
one question the repository cannot answer: which topic to work on.

The counterpart is `skills/clock-out/SKILL.md`.

## The two layers

A working day has two durable records, and they belong to different owners:

| Layer | Owner | Holds |
|---|---|---|
| Project | the repository being worked in | topic plans, project diary, issues, branches |
| Private | the user's own journal repository | the cross-project day, the daily focus, personal threads |

**Both layers are always considered.** A clock-in that only touches one of them
is incomplete, and it must say which one it skipped and why. A layer that is
absent is *recorded as absent*, never invented.

## Session lead

Exactly one skill leads an invocation. The lead does the orchestration; anything
it invokes runs **delegated** and does not orchestrate back.

- Invoked inside a project that uses this toolkit, **this skill leads**. It
  drives the project layer, then hands over to the private journal's own
  clock-in skill in delegated mode.
- Invoked outside such a project — the user says "clock in" with no project in
  context — the private journal's clock-in skill leads on its own. This skill is
  not involved, and the private journal skill must work without it.
- A delegated skill never sweeps other repositories and never delegates back.
  Without this rule the two layers call each other in a loop.

The multi-project view belongs to the private layer. This skill orients **one**
repository: the one it was invoked in.

## Workflow

**1. Establish the project state before asking anything.**

```sh
git status --short && git branch --show-current
git log --oneline -5
gh pr list --state open
gh issue list --state open --limit 20
```

Note anything that contradicts what the topic files will claim. Uncommitted
work, a branch that is not the base branch, an open pull request — these are
facts about where the last session stopped, and they outrank any file.

**2. Delegate to the project's own clock-in skill when it has one.**

Look for `skills/clock-in/SKILL.md` in the repository being worked in. When it
exists, read and execute it as the authoritative project-specific workflow: it
owns the project's paths, file formats, and diary wiring, and this skill owns
only the ritual around it. When it does not exist, use the default layout below.

**3. Resolve the private journal binding.** See "The private journal binding".
Recover its state *before* the focus question — an open day may be older than
today, and only the private layer knows.

**4. List the topics from the directory, not from an index.**

Every file in `progress/` is a topic; there is no index to go stale. For each
one, take when it was last touched from git rather than from the file:

```sh
git log -1 --format='%ad %s' --date=short -- progress/<file>
```

**5. Ask, once, which topic to continue.** Offer each existing topic, the
actionable topics the private layer returned, starting a new one, and working
without a topic — a one-off fix does not need a progress file, and creating one
for it is ceremony.

Ask this as a single question covering both layers. Do not pair it with a second
one; the answers collide. The private journal binding is settled in step 3, not
here.

**6. Read what the chosen topic depends on.**

- `progress/<topic>.adoc` — the plan and where it stands.
- The newest entry in the project's diary — what the last session learned, which
  is often why the plan says what it says.
- The issues the plan references, if the plan's next step names any.

**7. Report the delta, then start.** Three things, briefly: where the topic
stands, what the plan's next step is, and what has changed on the base branch
since the file was last touched. If the two disagree, say so and fix the file —
it describes now, so a stale statement in it is corrected on sight, not
preserved.

**8. For a new topic**, create `progress/<slug>.adoc` from
`templates/progress.adoc` and fill the plan **with** the owner, not for them. A
plan invented on their behalf is a guess wearing a checklist.

## The private journal binding

A private journal is per user, not per project. Its location must therefore never
be recorded in this toolkit or in a consuming project — it differs on every
machine, and a project repository is the wrong place to name it.

It is resolved at session start, in this order:

1. `ARCHITECTURE_KNOWLEDGE_TOOLKIT_JOURNAL` — a directory path, or `off`.
2. The user-level binding written at adapter installation:
   `${XDG_CONFIG_HOME:-$HOME/.config}/architecture-knowledge-toolkit/journal.conf`.
3. Neither is present: ask, once, and store the answer.

Read it with the helper rather than parsing the file by hand:

```sh
"$ARCHITECTURE_KNOWLEDGE_TOOLKIT"/adapters/shared/journal-config.sh get
```

It prints `enabled`, `path`, `clock_in`, and `clock_out`, and exits `3` when no
binding has been recorded yet.

**On exit 3, ask exactly one setup question**, before and separate from the topic
question: does the user keep a private journal, and if so where. Three answers,
two of them durable:

| Answer | Store it with |
|---|---|
| yes, at `<dir>` | `journal-config.sh set --path <dir>` |
| no, I do not keep one | `journal-config.sh disable` |
| not now | store nothing; ask again next session |

**"No" is an answer worth storing.** Without recording it, a user without a
private journal is asked again every single session, and the mechanism becomes
the thing people work around.

When the binding is enabled, read `<path>/<clock_in>` and execute it in
delegated mode. When the path is missing or unreachable — another machine, a
checkout not present — record the gap and finish the project layer anyway. The
private layer is never allowed to block the project layer.

## Direction of flow

Project findings flow **up** into the private journal. Nothing flows down.

What the private layer returns at clock-in — an open day, a focus, a personal
thread — belongs in the conversation, not in project files. The private path
itself never appears in a project artifact.

## Default layout

Used when the project has no clock-in skill of its own. A project-local skill may
narrow any of it; that is what a local skill is for.

- `progress/<topic>.adoc` — one file per topic, from `templates/progress.adoc`.
- The project's diary, in whatever form the project already keeps one.

## What a progress file is for

It is the plan and the current status of one topic, sitting next to the code and
present the moment the repository is checked out. That is what it adds over the
issue board: an order of work, and the reason for that order, which a board
cannot show.

It refers to issues by number and never restates them. The issue owns the
acceptance criteria; the file owns the sequence.

It carries no history. It describes now, is rewritten as often as needed, and is
deleted when its topic ends — what was learned along the way is in the diary by
then.

**No number in it that a command can produce.** Not test counts, not coverage,
not bundle sizes. Write the command instead. A number copied into a file nobody
re-runs is a claim that goes stale silently.

## What this skill does not do

- It does not decide the project's file formats or diary structure. A
  project-local clock-in skill owns those.
- It does not orchestrate other repositories. That is the private layer's job.
- It does not record where the private journal lives anywhere inside a
  repository.

## Supporting files

- `templates/progress.adoc` — the shape of a progress file. The only copy;
  `clock-out` references this one.
- `../../adapters/shared/journal-config.sh` — resolves and stores the private
  journal binding.
