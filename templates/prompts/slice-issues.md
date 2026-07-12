# Slice Issues Prompt

```text
Slice the following GitHub issue into reviewable implementation sub-issues:

<issue number or URL>

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

Read the parent issue body and comments, check existing open issues for
duplicates, and decide whether the work should become real GitHub sub-issues or
remain one PR with clearly separated commits. Make each slice independently
reviewable, small, ordered by dependency, and clear about scope and acceptance
criteria. Report created sub-issues and any fallback used.
```
