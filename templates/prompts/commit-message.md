# Commit Message Prompt

```text
Prepare a repository commit message for the current staged changes.

Use project-local contracts and skills first. If they do not cover this task,
locate toolkit guidance in this order:
1. If ARCHITECTURE_KNOWLEDGE_TOOLKIT is set, use that path.
2. Otherwise check ../architecture-knowledge-toolkit.
3. Otherwise check any project-local recorded toolkit reference, such as a
   submodule, vendored copy, or pinned path.
4. Otherwise use
   https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit,
   preferably at a pinned release tag or commit SHA.

Inspect the staged diff and any known issue number. Write a short imperative
summary. If the work belongs to a known issue, use the repository's issue
prefix convention. Add a body only when it helps explain why the change was
made.
```
