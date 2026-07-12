# Post-Merge Sync Prompt

```text
Synchronize this local checkout after the pull request has been integrated:

<pull request number or URL>

Use project-local contracts and skills first. If they do not cover this task,
locate toolkit guidance in this order:
1. If ARCHITECTURE_KNOWLEDGE_TOOLKIT is set, use that path.
2. Otherwise search upward from the project directory for a local
   architecture-knowledge-toolkit checkout: check ../architecture-knowledge-toolkit,
   then the same directory name in each parent directory up to the filesystem
   root.
3. Otherwise check any project-local recorded toolkit reference, such as a
   submodule, vendored copy, or pinned path.
4. Otherwise use
   https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit,
   preferably at a pinned release tag or commit SHA.

Verify the worktree is clean, identify the PR base branch, switch to that base
branch, fast-forward from the remote, confirm GitHub reports the PR as
integrated and the PR changes are present, then delete the local PR branch only
when it has no unmerged local commits. Delete the remote PR branch by default
after successful integration when GitHub confirms the PR was integrated and no
warning signs are present. Skip cleanup and report to the developer when there
are warning signs such as failed or unknown checks, unresolved merge state,
diverged local branch, unpushed local commits, uncertain PR state, or unclear
branch ownership. Never use destructive cleanup commands unless explicitly
requested.
```
