# Post-Merge Sync Prompt

```text
Synchronize this local checkout after the pull request has been merged:

<pull request number or URL>

Use project-local contracts and skills first. If they do not cover this task,
locate toolkit guidance in this order:
1. If ARCHITECTURE_KNOWLEDGE_TOOLKIT is set, use that path.
2. Otherwise check ../architecture-knowledge-toolkit.
3. Otherwise check any project-local recorded toolkit reference, such as a
   submodule, vendored copy, or pinned path.
4. Otherwise use
   https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit,
   preferably at a pinned release tag or commit SHA.

Verify the worktree is clean, identify the PR base branch, switch to that base
branch, fast-forward from the remote, confirm the merged changes are present,
and delete the merged local branch only when it has no unmerged local commits.
Never use destructive cleanup commands unless explicitly requested.
```
