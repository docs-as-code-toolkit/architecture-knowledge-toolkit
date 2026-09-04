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

## Never delegate to yourself

Every delegation in this skill finds its target by path, not by identity, and
three of those paths resolve back to this file:

- Inside the toolkit itself, `skills/clock-in/SKILL.md` "in the repository being
  worked in" **is** this file.
- A project that installed the toolkit's skills into its own `skills/` reaches
  this file through a symlink that looks project-local.
- A private journal bound to a repository whose clock skill defers back upward —
  the normal shape of a project delta — arrives here again by way of the
  binding.

So: **resolve every delegation target to its real path, following symlinks, and
compare it with the file you are executing.** Same file, and you are already the
delegate: do not delegate, and use the default layout instead.

The session lead rule does not cover this. It governs the loop *between* the two
layers and assumes the two skills are different files; self-delegation happens
*inside* one layer, where that rule never fires.

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

Every one of those four commands describes the *current* branch, plus whatever
branches happen to carry an open pull request. A branch with commits and no pull
request is invisible to all four, and that is the ordinary shape of work in
progress. So establish the state of the whole repository as well:

The enumeration names the base branch rather than assuming it, prints how far
each ref is ahead of and behind it, and ends in one verdict. Listing refs is not
the point — divergence from the base is, and a list of names still leaves the
comparison to whoever reads it.

```sh
gap=""

base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD) ||
  { echo "SWEEP: BLOCKED — UNAVAILABLE:base (run git remote set-head origin --auto once)"; exit 1; }
git fetch --quiet --prune origin ||
  { echo "SWEEP: BLOCKED — UNAVAILABLE:fetch"; exit 1; }
refs=$(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes/origin) ||
  { echo "SWEEP: BLOCKED — UNAVAILABLE:refs"; exit 1; }
names=$(printf '%s\n' "$refs" | sed 's|^origin/||' | sort -u) ||
  { echo "SWEEP: BLOCKED — UNAVAILABLE:dedup"; exit 1; }

report_ref() {
  if ! counts=$(git rev-list --left-right --count "$base...$1" 2>/dev/null); then
    gap="$gap UNAVAILABLE:divergence($1)"; return
  fi
  if ! newest=$(git log -1 --format=%cs "$1" 2>/dev/null); then
    gap="$gap UNAVAILABLE:date($1)"; return
  fi
  echo "$1: $(echo "$counts" | awk '{print $2}') ahead," \
       "$(echo "$counts" | awk '{print $1}') behind $base, newest $newest"
}

for name in $names; do
  case "$name" in "${base#origin/}" | origin | HEAD) continue ;; esac
  git show-ref --verify --quiet "refs/heads/$name" && has_local=yes || has_local=no
  git show-ref --verify --quiet "refs/remotes/origin/$name" && has_remote=yes || has_remote=no

  if [ "$has_local" = yes ] && [ "$has_remote" = yes ]; then
    git merge-base --is-ancestor "origin/$name" "$name" 2>/dev/null
    case $? in
      0) report_ref "$name" ;;
      1) echo "$name: origin/$name is not contained in local — both listed"
         report_ref "$name"
         report_ref "origin/$name" ;;
      *) gap="$gap UNAVAILABLE:ancestry($name)" ;;
    esac
  elif [ "$has_local" = yes ]; then
    report_ref "$name"
  else
    report_ref "origin/$name"
  fi
done

if [ -n "$gap" ]; then
  echo "SWEEP: BLOCKED —$gap"
  exit 1
fi
echo "SWEEP: CLEAR (base $base)"
```

**One entry per branch name, except where that would hide something.** A local
branch and its remote counterpart are the same work in two places only while
`origin/<name>` is an ancestor of the local ref. Then the local one is ahead of
it or equal to it, and reporting that one alone loses nothing.

When it is not an ancestor — the local branch is behind what was pushed, or the
two have diverged — collapsing them discards exactly the commits this sweep
exists to find. Both refs are listed then, and the pair is named as what it is.
That is a state of the repository rather than a failed query, so it is reported
and does not block. Where only one of the two exists, that one is used.

Without a checkout, the same question and the same verdict:

```sh
repo=<owner>/<repo>
gap=""

base=$(gh api "repos/$repo" --jq .default_branch 2>/dev/null) ||
  { echo "SWEEP: BLOCKED — UNAVAILABLE:default-branch"; exit 1; }
branches=$(gh api --paginate "repos/$repo/branches?per_page=100" --jq '.[].name' 2>/dev/null) ||
  { echo "SWEEP: BLOCKED — UNAVAILABLE:branch-list"; exit 1; }

for b in $branches; do
  [ "$b" = "$base" ] && continue
  if line=$(gh api "repos/$repo/compare/$base...$b" --jq \
      '"\(.ahead_by) ahead, \(.behind_by) behind" +
       (if (.commits | length) > 0
        then ", newest \((.commits | last).commit.committer.date[0:10])"
        else "" end)' 2>/dev/null); then
    echo "$b: $line"
  else
    gap="$gap UNAVAILABLE:compare($b)"
  fi
done

if [ -n "$gap" ]; then
  echo "SWEEP: BLOCKED —$gap"
  exit 1
fi
echo "SWEEP: CLEAR (base $base)"
```

`--paginate` is not decoration. Without it the listing stops after the first
page, and a repository with more than a hundred branches reports `SWEEP: CLEAR`
having looked at part of itself — the same silent incompleteness this section
exists to remove, arriving through the door marked "success". The checkout form
has no such limit; `for-each-ref` enumerates everything.

This is one repository's branches, not other repositories — the multi-project
view still belongs to the private layer.

**Both forms are fail-closed, and that is not decoration.** A query that did not
run says nothing about the branches, so every fetch is tested on its own and a
failed comparison is collected rather than skipped. Two shapes make this go
wrong quietly and both are avoided above: a `gh api` or `git` command as the left
member of a pipeline, whose failure the pipeline swallows, and a `while read` fed
by a pipe, which runs in a subshell and discards the gaps it collected. A session
that could not list the branches has not established that there were none.

**2. Delegate to the project's own clock-in skill when it has one.**

Look for `skills/clock-in/SKILL.md` in the repository being worked in, and apply
"Never delegate to yourself" to what you find. When it exists and is a different
file, read and execute it as the authoritative project-specific workflow: it owns
the project's paths, file formats, and diary wiring, and this skill owns only the
ritual around it. When it does not exist, or resolves to this file, use the
default layout below.

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

**7. Report the delta, then start.** Four things, briefly: where the topic
stands, what the plan's next step is, what has changed on the base branch since
the file was last touched, and which other refs are ahead of it. If the two disagree, say so and fix the file —
it describes now, so a stale statement in it is corrected on sight, not
preserved.

**8. For a new topic**, create `progress/<slug>.adoc` from
`templates/progress.adoc` and fill the plan **with** the owner, not for them. A
plan invented on their behalf is a guess wearing a checklist.

## Say what was read

This skill claims to start from the repository rather than from memory. A session
that read the issues, the diary and the topic files and a session that
reconstructed them from the conversation produce artifacts that look identical,
so the claim needs a trace or it is only an intention.

Record, in the layer that outlives the session, which repository artifacts this
session actually fetched — the branch enumeration, the issues read by number, the
topic files, the diary entry, the delegated skills — each with a reference a later
session can re-fetch. `clock-out/SKILL.md` says where that record lands.

Two rules keep it worth having:

- **An artifact this session did not fetch does not go in the list.** A plausible
  entry written from memory is worse than a short list, because it is the one
  thing a later session will trust without checking.
- **A failed fetch is an entry too**, naming what could not be read and why.

Be clear about how much this is worth. The branch enumeration above is enforced
by a command: run it or do not, the output is either there or it is not. This
record is enforced by review — nothing in the toolkit can tell a truthful list
from an invented one, because the diary form belongs to the project layer and
there is no single path to check. A consuming repository whose diary has a fixed
shape can count the section instead, and one does. Saying that plainly is part of
the rule: a guard that claims more enforcement than it has is the same defect one
level up.

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
delegated mode — after checking it against "Never delegate to yourself", and
after checking that the binding does not name the repository being worked in. A
binding that points at the current repository describes one layer, not two.

**A delegated invocation does not resolve the binding at all.** The lead resolved
it already; re-resolving is what turns a project delta into a cycle. When the path is missing or unreachable — another machine, a
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
