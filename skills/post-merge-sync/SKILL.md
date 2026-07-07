---
name: post-merge-sync
description: "Synchronize a local checkout after a pull request has been integrated: verify a clean worktree, switch to the base branch, fast-forward from the remote, confirm the PR changes are present, and clean up local and remote PR branches when safe. Use when an agent is asked to clean up after an integrated PR or return the repository to the latest base branch."
---

# Post-Merge Sync

Use this workflow after a pull request has been integrated so future work starts
from the updated base branch instead of an obsolete PR branch. Pull requests are
normally integrated with a linear history by
`gh pr merge <number> --rebase --delete-branch`; this workflow verifies the
result and finishes safe local cleanup.

## Workflow

1. Inspect the current branch and worktree.
2. If unrelated local changes are present, do not switch branches until those
   changes are preserved or the user confirms how to handle them.
3. Identify the pull request base branch, usually `main`.
4. Switch to the base branch.
5. Fetch or pull from the remote with a fast-forward-only update.
6. Confirm GitHub reports the pull request as integrated and the base branch
   contains the PR changes.
7. Delete the local PR branch only when it has no unmerged local commits.
8. Delete the remote PR branch after successful integration when GitHub confirms
   the PR was integrated and there are no anomalies.
9. Report the final branch, latest commit, and whether cleanup was completed or
   skipped.

Determine the base branch from the pull request metadata when possible, for
example with `gh pr view <pr> --json baseRefName`, or from the repository
default branch when the PR context is unavailable.

## Commands

Prefer non-destructive commands:

```sh
git status --short --branch
git switch <base-branch>
git pull --ff-only
git branch --merged <base-branch>
git branch -d <merged-branch>
git push origin --delete <merged-branch>
```

Use the actual base branch when the pull request targeted something other than
`main`.

When a separate fetch step is clearer, prefer:

```sh
git fetch origin
git merge --ff-only origin/<base-branch>
```

Run `git fetch --prune origin` before listing merged branches when remote branch
state may be stale. If GitHub already deleted the remote branch, treat that as a
successful no-op.

## Safety Rules

- Never use `git reset --hard` for post-merge cleanup.
- Never delete a branch with `git branch -D` unless the user explicitly asks
  for forced deletion and understands that unmerged local commits may be lost.
- Do not delete local or remote branches when there are warning signs, such as
  failed or unknown checks, unresolved merge state, a diverged local branch,
  unpushed local commits, uncertain PR state, or unclear branch ownership.
  Report the situation and let the developer decide.
- Delete the remote PR branch by default after successful integration when
  GitHub confirms the PR was integrated and no warning signs are present.
- If the remote update cannot fast-forward, stop and explain the divergence.
  Preserve local commits by creating a backup branch before asking the user how
  to proceed.
- If the branch was already deleted locally or remotely, report that as a
  harmless no-op.

## Relationship To Issue Implementation

After a pull request opened through `../implement-issue-workflow/SKILL.md` is
merged, use this skill to return the checkout to the latest base branch before
starting new issue work.
