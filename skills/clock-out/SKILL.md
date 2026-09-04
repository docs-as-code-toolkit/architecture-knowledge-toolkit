---
name: clock-out
description: End a working session by refreshing the topics touched, writing the project diary entry, and carrying the day's findings up into the user's private journal. Use when the owner calls it a day, says clock out, before a long break, or when a topic is being put on ice.
---

# Clock Out

## Purpose

Leave the repository in a state that a session tomorrow can resume from without
asking anyone — and carry what the day produced up into the user's own journal
in the same move, so the two records cannot drift apart.

Two artifacts in the project layer, and the split between them is the whole
point:

- `progress/<topic>.adoc` — **where we are.** Present tense, rewritten
  wholesale, no history.
- The project diary entry — **what we learned.** Past tense, never revised once
  the day is closed.

A sentence that fits both goes in the diary, because that is the one that may
not be rewritten later.

The counterpart is `skills/clock-in/SKILL.md`, which also defines the two layers,
the session lead rule, and how the private journal binding is resolved. Read that
section there rather than restating it.

## Session lead

Invoked inside a project that uses this toolkit, **this skill leads**: it
finishes the project layer, then hands the day's findings to the private
journal's clock-out skill in delegated mode.

Invoked outside such a project — "clock out" said with no project in context —
the private journal's own clock-out skill leads, this skill is not involved, and
the private journal must be maintainable with nothing but its own skills.

A delegated skill does not sweep other repositories and does not delegate back.
It also does not resolve the private journal binding: the lead resolved it
already, and re-resolving is what turns a project delta into a cycle.

**"Never delegate to yourself" in `skills/clock-in/SKILL.md` applies to every
delegation below.** Both delegation targets here are found by path, and both can
resolve back to this file — inside the toolkit itself, and through a project that
installed the toolkit's skills into its own `skills/`. Resolve the target to its
real path and compare it with the file you are executing before running it.

## Workflow

**1. Close the loop on the work itself.** Nothing uncommitted without a reason
stated, every open pull request named with its check status, every red check
named. Take these from the tools, not from what happened in the session:

```sh
git status --short
gh pr list --state open
gh pr checks <number>
```

These see the current branch and whatever carries an open pull request. Establish
the state of the whole repository too, with the branch enumeration under step 1
of `../clock-in/SKILL.md` — that file owns the command, and a second copy here
would get its own chance to drift from it. A branch that moved today and has no
pull request is exactly what a closing report must not miss.

A session does not end tidily just because it stopped.

**2. Delegate to the project's own clock-out skill when it has one.** Look for
`skills/clock-out/SKILL.md` in the repository being worked in. When it exists and
is a different file, execute it as the authoritative project-specific workflow —
it owns the project's paths, file formats, diary wiring, and confirmation rules.
Preserve its stopping conditions. When it does not exist, or resolves to this
file, apply steps 3 to 5 against the default layout in
`skills/clock-in/SKILL.md`.

**3. Refresh the progress file for every topic touched.**

- Overwrite it. It describes now; there is nothing in it worth preserving as
  history.
- Move the plan's steps to their real state, and correct the plan itself if the
  day showed the order was wrong. The plan is the thing worth having — a
  checklist that no longer reflects the intended order is worse than none.
- **Do not mark a step done that no check confirmed.** "Done" in a file that
  outlives the session is a claim, and it will be believed.
- If the topic is going on ice, say so together with **why** and what would
  bring it back. "Paused" without a resumption condition is a file nobody will
  ever reopen.
- If the topic ended, delete the file. What it was for is in the diary by then.

**4. Write the project diary entry** from the commit history, the issues, and
the pull requests — not from the session. At clock-out the day is fresh, which
is exactly when memory feels reliable enough to skip the check.

The entry carries what this session actually fetched, under the rules in "Say
what was read" in `../clock-in/SKILL.md`: references a later session can
re-fetch, nothing that was not fetched, and every failed fetch named. That list
is what makes the sentence above checkable by a reader instead of merely
asserted.

**5. Say what is open — in the files, not only in the conversation.** The chat
is gone tomorrow. A thread that outlives its topic goes to the project's
long-lived thread list; one that dies with the topic stays in the progress file.

**6. Hand the day up to the private journal.** Skip this step entirely when this
invocation is itself delegated. Otherwise resolve the binding as described in
`skills/clock-in/SKILL.md`. When it is enabled, and the binding names neither
this file nor the repository being worked in, read `<path>/<clock_out>` and
execute it in delegated mode, handing over the record below. When it is
disabled, unbound, or unreachable, say so in the closing report and finish
anyway — the private layer never blocks the project layer.

**7. Report** what was written in each layer, and name every layer that was
skipped together with the reason.

## The handover record

One record per project per day. It is what the project layer knows and the
private layer cannot reconstruct:

| Field | Content |
|---|---|
| `project` | the repository, as the private journal names it |
| `status` | one line, verified against the tools |
| `findings` | what was learned that is **not** specific to this project; may be empty |
| `evidence` | pull requests, commits, issues — links, not prose |
| `read` | what this session fetched to reach the above, as re-fetchable references |
| `threads` | open threads that outlive this project |

Rules that make it safe to run more than once:

- **`evidence` and `read` are different sets.** `evidence` is what the day
  produced; `read` is what the session fetched to find out. They overlap and are
  routinely not the same, and collapsing them loses the only statement that says
  the day was reconstructed from the repository.
- **Keyed by project and day.** A second clock-out on the same day replaces that
  project's entry; it never appends a duplicate.
- **The private layer owns the day.** It decides which day file the record lands
  in, in its own timezone, in its own format, under its own branch or pull
  request workflow. This skill hands over content, never file paths.
- **Summarize, do not copy.** The project diary keeps the narrative; the private
  journal gets the summary and the project-neutral findings. Duplicating the
  narrative upward makes both copies stale.
- **The flow is one-way.** Nothing from the private journal is written into
  project files, and the private path never appears in a project artifact.

## What this skill does not do

- It does not decide whether work is finished. Checks and reviews do that.
- It does not merge, push to the base branch, or close issues to make a day look
  complete.
- It does not restate the commit format or the pull-request workflow; those are
  `skills/commit-message/SKILL.md` and `skills/implement-issue-workflow/SKILL.md`.
- A clock-out authorizes the two layers of this handoff. It does not authorize
  unrelated merges, issue closures, or work outside these skills.

## Supporting files

- `../clock-in/templates/progress.adoc` — the shape of a progress file. One
  copy, deliberately, so the two skills cannot drift apart.
- `../../adapters/shared/journal-config.sh` — resolves and stores the private
  journal binding.
