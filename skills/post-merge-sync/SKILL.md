---
name: post-merge-sync
description: "Synchronize a local checkout after a pull request has been merged: verify a clean worktree, switch to the base branch, fast-forward from the remote, confirm the merge commit is present, and optionally remove merged local branches. Use when an agent is asked to clean up after a merged PR or return the repository to the latest main branch."
---

# Post-Merge Sync

Use this workflow after a pull request has been merged so future work starts
from the integrated base branch instead of an obsolete PR branch.

## Workflow

1. Inspect the current branch and worktree.
2. If unrelated local changes are present, do not switch branches until those
   changes are preserved or the user confirms how to handle them.
3. Identify the pull request base branch, usually `main`.
4. Switch to the base branch.
5. Fetch or pull from the remote with a fast-forward-only update.
6. Confirm the base branch contains the merged PR changes.
7. Delete the merged local PR branch only when it has no unmerged local commits.
8. Report the final branch, latest commit, and whether cleanup was skipped.

## Commands

Prefer non-destructive commands:

```sh
git status --short --branch
git switch main
git pull --ff-only
git branch --merged main
git branch -d <merged-branch>
```

Use the actual base branch when the pull request targeted something other than
`main`.

## Safety Rules

- Never use `git reset --hard` for post-merge cleanup.
- Never delete a branch with `git branch -D` unless the user explicitly asks
  for forced deletion and understands that unmerged local commits may be lost.
- Do not delete remote branches unless the user explicitly requests it.
- If the remote update cannot fast-forward, stop and explain the divergence.
- If the branch was already deleted locally or remotely, report that as a
  harmless no-op.

## Relationship To Issue Implementation

After a pull request opened through `../implement-issue-workflow/SKILL.md` is
merged, use this skill to return the checkout to the latest base branch before
starting new issue work.
