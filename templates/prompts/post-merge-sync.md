# Post-Merge Sync Prompt

```text
Synchronize this local checkout after the pull request has been merged:

<pull request number or URL>

If you have a local skill for this task, use it. If not, search for the skill in
the local architecture-knowledge-toolkit. If no local
architecture-knowledge-toolkit is available, search for a suitable skill in
https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit.

Verify the worktree is clean, identify the PR base branch, switch to that base
branch, fast-forward from the remote, confirm the merged changes are present,
and delete the merged local branch only when it has no unmerged local commits.
Never use destructive cleanup commands unless explicitly requested.
```
